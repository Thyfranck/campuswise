class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book, :payment

  #  def after_save(record)
  #    if record.class == Payment
  #      if record.status == STATUS[:paid]
  #        Notification.email_after_payment(record).deliver
  #      end
  #    end
  #  end

  def before_create(record)
    if record.class == Exchange
      return false if Book.find(record.book_id).available == false
      return false if Book.find(record.book_id).user.id == User.find(record.user_id).id
      return false if record.user.billing_setting.blank? #check if the user has credit card information
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

  def before_update(record)
    if record.class == Exchange      
      if record.payment.status == Payment::STATUS[:paid]
        return true
      else
        return false
      end
    end
  end

  def after_update(record)
    if record.class == Payment
      if record.status == Payment::STATUS[:paid]
        @request_sender = User.find(record.exchange.user_id)
        @request_receiver = User.find(record.exchange.book.user_id)
        @requested_book = Book.find(record.exchange.book)
        @exchange = record.exchange
        if @requested_book.available == true
          @exchange.update_attribute(:accepted, true)
          @requested_book.update_attribute(:available, false)
          @dashboard_notification = DashboardNotification.new(
            :user_id => @request_sender.id,
            :exchange_id => record.exchange.id,
            :content => "Congratulation #{@request_receiver.name} has accepted your Borrow Proposal for the book titled \"<a href='/books/#{@requested_book.id}' target='_blank'> #{@requested_book.title.truncate(25)} </a> \" "
          )
          @dashboard_notification.save
          Notification.notify_book_borrower_accept(@request_receiver, @request_sender, @requested_book).deliver
          @to = @request_sender.phone
          @body = "Congratulation #{@request_receiver.name} has accepted your borrow request for the book \"#{@requested_book.title.truncate(50)}\"-Campuswise"
          TwilioRequest.send_sms(@body, @to)
          record.exchange.destroy_other_pending_requests
        end
      elsif record.status == Payment::STATUS[:failed]
        record.exchange.destroy
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
      if record.payment.status == Payment::STATUS[:pending]
        if Book.find(record.book_id).available == true
          @dashboard_notification = DashboardNotification.new(
            :user_id => @request_sender.id,
            :exchange_id => record.id,
            :content => "Sorry request for the book titled \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected by the user. Please try other sometime."
          )
          @dashboard_notification.save
          Notification.notify_book_borrower_reject(@request_receiver, @request_sender, @requested_book).deliver
          @to = @request_sender.phone
          @body = "Sorry borrow request for the book \"#{@requested_book.title.truncate(50)}\" was rejected by the user -Campuswise"
          TwilioRequest.send_sms(@body, @to)
        end
      elsif record.payment.status == Payment::STATUS[:failed]
        if Book.find(record.book_id).available == true
          @dashboard_notification = DashboardNotification.new(
            :user_id => @request_sender.id,
            :exchange_id => record.id,
            :content => "Sorry request for the book titled \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected due to payment error."
          )
          @dashboard_notification.save
          Notification.notify_book_borrower_reject(@request_receiver, @request_sender, @requested_book).deliver
          @to = @request_sender.phone
          @body = "Sorry borrow request for the book \"#{@requested_book.title.truncate(50)}\" was rejected due to payment error -Campuswise"
        end
      end
    end
  end
end
