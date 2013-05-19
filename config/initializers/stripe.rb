if Rails.env.development?
  Stripe.api_key = "sk_test_W3fW7v8oI9NJrviXc1jV58xw"     # test account
  STRIPE_PUBLIC_KEY = "pk_test_RIAHJE3jDPu7SKcnQUr2rJu9"  # test account
elsif Rails.env.staging?
  Stripe.api_key = "sk_test_W3fW7v8oI9NJrviXc1jV58xw"     # test account
  STRIPE_PUBLIC_KEY = "sk_test_W3fW7v8oI9NJrviXc1jV58xw"  # test account
elsif Rails.env.production?
  Stripe.api_key = "sk_live_jQ0IlPMXQJ4z0WiFK8ARKa4y"     # Live account
  STRIPE_PUBLIC_KEY = "pk_live_sAkQxoL9kpnbEBNwxQPDQYMR"  # Live account
end