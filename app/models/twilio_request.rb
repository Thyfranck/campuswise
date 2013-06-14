class TwilioRequest
  if Rails.env.development?
    @account_sid = 'AC1d01a0bb6615470f7c42ca3d37cca75c'
    @auth_token = 'a324102c544d482ef066e844c9c3d216'
    @from = "+17034369992"
  elsif Rails.env.staging? or Rails.env.production?
    @account_sid = 'AC1d01a0bb6615470f7c42ca3d37cca75c'
    @auth_token = 'a324102c544d482ef066e844c9c3d216'
    @from = "+15755191259"
  end

  def self.send_sms(body, to, from = @from)
    begin
      @client = Twilio::REST::Client.new(@account_sid, @auth_token)
      @client.account.sms.messages.create(
        :from => from,
        :to => to,
        :body => body
      )
    rescue Timeout::Error
      return true
    end
  end
end