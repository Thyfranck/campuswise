class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book

  def before_create(record)
    if record.class == Exchange
      if Book.find(record.book_id).available == false #check if the book is available
        return false
      end

      if Book.find(record.book_id).user.id == User.find(record.user_id).id #making sure  the user doesn't exchange between in his own books.
        return false
      end
    end
  end
  
  def after_create(record)
    if record.class == Exchange
      @request_sender = User.find(record.user_id)
      @request_receiver = User.find(record.book.user_id)
      @requested_book = Book.find(record.book_id)
      
      @dashboard_notification =  DashboardNotification.new(
        :user_id => @request_receiver.id,
        :exchange_id => record.id,
        :content => "#{@request_sender.name} wants to borrow your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" ")
      if @dashboard_notification.save
        Notification.notify_book_owner(@request_receiver, @request_sender, @requested_book).deliver
        @to = @request_receiver.phone
        @body = "#{@request_sender.name} wants to borrow \"#{@requested_book.title.truncate(50)}\"to accept reply yes#{record.id},to ignore reply no#{record.id}-Campuswise"
        TwilioRequest.send_sms(@body, @to)
      end
    end
  end

  def after_update(record)
    
    if record.class == Exchange and record.accepted == true
      @request_sender = User.find(record.user_id)
      @request_receiver = User.find(record.book.user_id)
      @requested_book = Book.find(record.book)

      if Book.find(record.book_id).available == true
        @old_dashboard_notification =  DashboardNotification.find(record.dashboard_notification)
        @old_dashboard_notification.destroy
        @dashboard_notification = DashboardNotification.new(
          :user_id => @request_sender.id,
          :exchange_id => record.id,
          :content => "Congratulation #{User.find(record.book.user_id).name} has accepted your Borrow Proposal for the book titled \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" "
        )
        Book.find(record.book_id).update_attribute(:available, false)
        @dashboard_notification.save
        Notification.notify_book_borrower_accept(@request_receiver, @request_sender, @requested_book).deliver
        @to = @request_sender.phone
        @body = "Congratulation #{@request_receiver.name} has accepted your borrow request for the book \"#{@requested_book.title.truncate(50)}\"-Campuswise"
        TwilioRequest.send_sms(@body, @to)
        record.destroy_other_pending_requests
      end
    end
  end

  def before_destroy(record)
    
    if record.class == Book
      return false if record.lended == true
      @exchanges = Exchange.where(:book_id => record.id)
      @notification = DashboardNotification.where(:exchange_id => @exchanges)
      @notification.each {|d| d.destroy}
      @exchanges.each {|d| d.destroy}
    end

    if record.class == Exchange
      @request_sender = User.find(record.user_id)
      @request_receiver = User.find(record.book.user_id)
      @requested_book = Book.find(record.book)
      if Book.find(record.book_id).available == true
        @old_dashboard_notification =  DashboardNotification.find(record.dashboard_notification)
        @old_dashboard_notification.destroy
        @dashboard_notification = DashboardNotification.new(
          :user_id => @request_sender.id,
          :exchange_id => record.id,
          :content => "Sorry request for the book titled \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected. Please try other sometime."
        )
        @dashboard_notification.save
        Notification.notify_book_borrower_reject(@request_receiver, @request_sender, @requested_book).deliver
        @to = @request_sender.phone
        @body = "Sorry borrow request for the book \"#{@requested_book.title.truncate(50)}\" was rejected this time -Campuswise"
        TwilioRequest.send_sms(@body, @to)
      elsif Book.find(record.book_id).available == false
        Book.find(record.book_id).update_attribute(:available, true)
      end
    end
  end
end
