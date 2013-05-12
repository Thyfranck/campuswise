class TwilioRequest
  if Rails.env.development?
    @account_sid = '	AC03a32e8221afe3c26d162d525a11f47b'
    @auth_token = '6443aeaa6891efe7f7e87b7fbd5c98c6'
  elsif Rails.env.staging? or Rails.env.production?
    @account_sid = ''
    @auth_token = ''
  end

  def self.send_sms(body, to, from = "+13212852857")
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
    @client.account.sms.messages.create(
      :from => from,
      :to => to,
      :body => body
    )
  end
end