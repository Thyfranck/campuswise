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
    
  end

  def send_sms_to_borrower
    @book_borrower = payment.exchange.user
    @to = @book_borrower.phone
    @body = "Lending time for the book titled \"#{payment.exchange.book.title.truncate(30)}\" is over. Please return the book to the owner. Ignore if already returned.-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def send_sms_to_lender
    @book_lender = Book.find(payment.exchange.book_id).user
    @to = @book_lender.phone
    @body = "Lending time for the book titled \"#{payment.exchange.book.title.truncate(30)}\" is over. Please inform us while the book is returned or not.-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end
end
