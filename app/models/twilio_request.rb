class TwilioRequest
  if Rails.env.development?
    @account_sid = 'ACb0deab9f219b8e066b5e05672105b973'
    @auth_token = '3b64a49adb2dbbfca04db68a63acd4de'
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