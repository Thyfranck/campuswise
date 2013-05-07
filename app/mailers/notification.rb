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

  def notify_book_owner(owner, borrower, book)
    @user = owner
    @borrower  = borrower
    @book = book
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "You have received a book borrow request - CampusWise")
  end

  def notify_book_borrower_accept(owner, borrower, book)
    @user = borrower
    @owner  = owner
    @book = book
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Congratulation Your Borrow request has been accepted - CampusWise")
  end

  def notify_book_borrower_reject(owner, borrower, book)
    @user = borrower
    @owner  = owner
    @book = book
    @url = dashboard_url
    headers['X-SMTPAPI'] = "{\"category\" : \"Exchange Alert\"}"
    mail(:to => @user.email,
      :subject => "Your book borrow request was rejected - CampusWise")
  end
end
