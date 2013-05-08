class TwilioRequest
  if Rails.env.development?
    @account_sid = 'ACc31a5fe9fd352e8ab8d266ece26a4fda'
    @auth_token = 'be2a9b437bac5c870641a81bb985f016'
  elsif Rails.env.staging? or Rails.env.production?
    @account_sid = ''
    @auth_token = ''
  end

  def self.send_verification_code(from, to, body)
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
    @client.account.sms.messages.create(
      :from => from,
      :to => to,
      :body => body
    )
  end
end