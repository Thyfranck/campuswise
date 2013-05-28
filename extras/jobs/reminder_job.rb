class Jobs::ReminderJob < Struct.new(:payment)

  def perform
    send_dashboard_notifications
    Notification.send_reminder_email_to_borrower(payment).deliver
    Notification.send_reminder_email_to_lender(payment).deliver
    send_sms_to_borrower
    send_sms_to_lender
  end
  
  private

  def send_dashboard_notifications
    @borrower_dashboard_notification =  DashboardNotification.new(
      :user_id => payment.exchange.user,
      :exchange_id => payment.exchange.id,
      :content => "Lending date for the book titled \"<a href='/books/#{payment.exchange.book.id}' target='_blank'> #{payment.exchange.book.title.truncate(25)} is over. Please return the book to the owner.")
    @borrower_dashboard_notification.save

    @lender_dashboard_notification =  DashboardNotification.new(
      :user_id => payment.exchange.book.user,
      :exchange_id => payment.exchange.id,
      :content => "Please inform us when and wheather the book titled \"<a href='/books/#{payment.exchange.book.id}' target='_blank'> #{payment.exchange.book.title.truncate(25)} </a> \" is returned. You can inform us \"<a href='/borrow_requests' target='_blank'> here </a> \"")
    @lender_dashboard_notification.save
  end

  def send_sms_to_borrower
    @book_borrower = payment.exchange.user
    @to = @book_borrower.phone
    @body = "Lending time for the book titled \"#{payment.exchange.book.title.truncate(30)}\" is over. Please return the book to the owner. Ignore if already returned.-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def send_sms_to_lender
    @book_lender = payment.exchange.book.user
    @to = @book_lender.phone
    @body = "Lending time for the book titled \"#{payment.exchange.book.title.truncate(30)}\" is over. Please inform us while the book is returned or not. When you receive the book sms us \"RECEIVED #{payment.exchange.id}\" and if you not then sms \"NOT-RECEIVED #{payment.exchange.id}\"-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end
end
