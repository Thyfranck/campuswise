class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book
  def after_create(record)
    @request_sender = User.find(record.user_id)
    @request_receiver = User.find(record.book.user_id)
    @requested_book = Book.find(record.book)
    
    if record.class == Exchange
      @dashboard_notification =  DashboardNotification.new(
        :user_id => @request_receiver.id,
        :exchange_id => record.id,
        :content => "#{@request_sender.name} wants to borrow your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" ")
      if @dashboard_notification.save
        Notification.notify_book_owner(@request_receiver, @request_sender, @requested_book).deliver
      end
    end
  end

  def after_update(record)
    if record.class == Exchange and record.accepted == true
      @request_sender = User.find(record.user_id)
      @request_receiver = User.find(record.book.user_id)
      @requested_book = Book.find(record.book)
      
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
    end
  end

  def before_destroy(record)
    
    if record.class == Book
      @exchanges = Exchange.where(:book_id => record.id)
      @notification = DashboardNotification.where(:exchange_id => @exchanges)
      @notification.each {|d| d.destroy}
      @exchanges.each {|d| d.destroy}
    end

    if record.class == Exchange
      @request_sender = User.find(record.user_id)
      @request_receiver = User.find(record.book.user_id)
      @requested_book = Book.find(record.book)
      
      @old_dashboard_notification =  DashboardNotification.find(record.dashboard_notification)
      @old_dashboard_notification.destroy
      @dashboard_notification = DashboardNotification.new(
        :user_id => @request_sender.id,
        :exchange_id => record.id,
        :content => "Sorry request for the book titled \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected. Please try other sometime."
      )
      @dashboard_notification.save
      Notification.notify_book_borrower_reject(@request_receiver, @request_sender, @requested_book).deliver
    end
  end
  
end
