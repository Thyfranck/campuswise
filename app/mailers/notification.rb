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
  
  def charge_succeeded(event_id)
    @event = BillingEvent.find(event_id)
    @user = @event.user
    require "yaml"
    @charge = HashWithIndifferentAccess.new(YAML.load @event.response)
    headers['X-SMTPAPI'] = "{\"category\" : \"Payment Succeeded\"}"
    mail(:to => @user.email,
      :subject => "Thanks for your payment!")
  end

  def charge_failed(event_id)
    @event = BillingEvent.find(event_id)
    @user = @event.user
    @business = @event.payment.business
    require "yaml"
    @charge = HashWithIndifferentAccess.new(YAML.load @event.response)
    headers['X-SMTPAPI'] = "{\"category\" : \"Payment Failed\"}"
    mail(:to => @user.email,
      :subject => "Your payment is failed!")
  end

  def email_after_payment(payment)
    @business = payment.business
    @user = payment.business.user
    headers['X-SMTPAPI'] = "{\"category\" : \"Thank You!\"}"
    mail(:to => @user.email,
      :subject => "Thank you for forming your business entity with CampusWise!",
      :bcc => "info@campuswise.com")
  end
end
