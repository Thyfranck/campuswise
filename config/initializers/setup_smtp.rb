ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => 'smtpout.secureserver.net',
  :domain  => 'campuswise.com',
  :port      => 3535,
  :user_name => 'info@campuswise.com',
  :password => 'virginia10',
  :authentication => :plain
}