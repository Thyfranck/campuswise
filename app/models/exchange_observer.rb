class ExchangeObserver < ActiveRecord::Observer
  observe :exchange
  def after_create(record)
    @request_sender = User.find(record.user_id)
    @request_receiver = User.find(record.book.user_id)
    @requested_book = Book.find(record.book)
    
    if record.class == Exchange
      @dashboard_notification =  DashboardNotification.new(
        :user_id => @request_receiver.id,
        :exchange_id => record.id,
        :content => "#{@request_sender.name} wants to borrow your book \"#{@requested_book.title}\" ")
      @dashboard_notification.save
    end
  end

  def after_update(record)
    @request_sender = User.find(record.user_id)
    @request_receiver = User.find(record.book.user_id)
    @requested_book = Book.find(record.book)

    if record.class == Exchange and record.accepted == true
      @old_dashboard_notification =  DashboardNotification.find(record.dashboard_notification)
      @old_dashboard_notification.destroy
      @dashboard_notification = DashboardNotification.new(
        :user_id => @request_sender.id,
        :exchange_id => record.id,
        :content => "Congratulation #{User.find(record.book.user_id).name} has accepted your Borrow Proposal for the book titled \"#{record.book.title}\" "
      )
      Book.find(record.book).update_attribute(:available, false)
      @dashboard_notification.save
    end

    if record.class == Exchange and record.accepted == false
      @old_dashboard_notification =  DashboardNotification.find(record.dashborad_notification)
      @old_dashboard_notification.destroy
      @dashboard_notification = DashboardNotification.new(
        :user_id => @request_sender.id,
        :exchange_id => record.id,
        :content => "Sorry request for the book titled \"#{record.book.title}\" was rejected. Please try other sometime."
      )
    end
  end
end
