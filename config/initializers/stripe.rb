if Rails.env.development?
  Stripe.api_key = "sk_test_dk1slzBBUUwbp9ENw3zpoJXj"     # test account
  STRIPE_PUBLIC_KEY = "pk_test_ouqtMfkIJlIf4t1VfWWZn1P8"  # test account
elsif Rails.env.staging?
  Stripe.api_key = "sk_live_jQ0IlPMXQJ4z0WiFK8ARKa4y"     # Live account
  STRIPE_PUBLIC_KEY = "pk_live_sAkQxoL9kpnbEBNwxQPDQYMR"  # Live account
elsif Rails.env.production?
  Stripe.api_key = "sk_live_jQ0IlPMXQJ4z0WiFK8ARKa4y"     # Live account
  STRIPE_PUBLIC_KEY = "pk_live_sAkQxoL9kpnbEBNwxQPDQYMR"  # Live account
end