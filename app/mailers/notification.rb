class Notification < ActionMailer::Base
  default :from => "\"CampusWise\" <info@campuswise.com>"

  def activation_needed_email(user)
    @user = user
    @url  = activate_user_url(user.activation_token)
    headers['X-SMTPAPI'] = "{\"category\" : \"Activation Needed\"}"
    mail(:to      => user.email,
      :subject => "Welcome to CampusWise")
  end

  def activation_success_email(user)
    @user = user
    @url  = login_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Welcome Email\"}"
    mail(:to => user.email,
      :subject => "Your account is now activated - CampusWise")
  end

  def reset_password_email(user)
    @user = user
    @url  = edit_password_reset_url(user.reset_password_token)
    headers['X-SMTPAPI'] = "{\"category\" : \"Password Help\"}"
    mail(:to => user.email,
      :subject => "Your password reset instructions - CampusWise")
  end

  def notify_book_borrower_failed_to_charge(exchange)
    @user = exchange.user
    @book = exchange.book
    @message = exchange.declined
    headers['X-SMTPAPI'] = "{\"category\" : \"Card Error Alert\"}"
    mail(:to => @user.email,
      :subject => "Borrow request failed - CampusWise")
  end

  def notify_book_owner(exchange)
    @user = exchange.book.user
    @borrower  = exchange.user
    @book = exchange.book
    @exchange = exchange
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "You have received a book borrow request - CampusWise")
  end

  def notify_book_borrower_accept(exchange)
    @user = exchange.user
    @book = exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your Borrow request has been accepted by the book owner - CampusWise")
  end

  def notify_book_borrower_reject_by_user(exchange)
    @user = exchange.user
    @owner  = exchange.book.user
    @book = exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your book borrow request was rejected by the owner - CampusWise")
  end

  def notify_book_borrower_reject_for_payment(exchange)
    @user = exchange.user
    @owner  = exchange.book.user
    @book = exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your book borrow request was rejected due to your card error - CampusWise")
  end

  def email_after_payment(payment)
    @user = payment.exchange.user
    @book = payment.exchange.book
    @amount = payment.payment_amount
    headers['X-SMTPAPI'] = "{\"category\" : \"Payment Alert\"}"
    mail(:to => @user.email,
      :subject => "Your payment was successfully received - CampusWise")
  end

  def notify_book_borrower_exchange_successfull(payment)
    @user = payment.exchange.user
    @owner = payment.exchange.book.user
    @book = payment.exchange.book
    @exchange = payment.exchange
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Congratulation Your Borrow request is now complete - CampusWise")
  end

  def notify_book_owner_exchange_successfull(payment)
    @user = payment.exchange.book.user
    @borrower = payment.exchange.user
    @book = payment.exchange.book
    @exchange = payment.exchange
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Congratulation Your Book lending process is complete - CampusWise")
  end

  def send_reminder_email_to_borrower(payment)
    @owner = payment.exchange.book.user
    @user = payment.exchange.user
    @book = payment.exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Reminder Alert\"}"
    mail(:to => @user.email,
      :subject => "Please return the book \"#{@book.title.truncate(20)}\" - CampusWise")
  end

  def send_reminder_email_to_lender(payment)
    @user = payment.exchange.book.user
    @borrower = payment.exchange.user
    @book = payment.exchange.book
    headers['X-SMTPAPI'] = "{\"category\" : \"Reminder Alert\"}"
    mail(:to => @user.email,
      :subject => "Please inform when the book \"#{@book.title.truncate(20)}\" is returned - CampusWise")
  end
end
