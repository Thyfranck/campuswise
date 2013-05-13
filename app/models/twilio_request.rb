class TwilioRequest
  if Rails.env.development?
    #my account
    #    @account_sid = '	AC03a32e8221afe3c26d162d525a11f47b'
    #    @auth_token = '6443aeaa6891efe7f7e87b7fbd5c98c6'
    #client account
    @account_sid = 'AC1d01a0bb6615470f7c42ca3d37cca75c'
    @auth_token = 'a324102c544d482ef066e844c9c3d216'
  elsif Rails.env.staging? or Rails.env.production?
    @account_sid = 'AC1d01a0bb6615470f7c42ca3d37cca75c'
    @auth_token = 'a324102c544d482ef066e844c9c3d216'
  end

  def self.send_sms(body, to, from = "+17034369992")
    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
    @client.account.sms.messages.create(
      :from => from,
      :to => to,
      :body => body
    )
  end
end