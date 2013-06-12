Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '362079183898081', '85d8bc70eb7545acd025c6d9cd0deab2',
           :display => 'popup'
end

FACEBOOK_APP_ID = '362079183898081'