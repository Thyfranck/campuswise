class BillingSetting < ActiveRecord::Base
  attr_accessible :card_expiry_date, :card_holder_name, :card_last_four_digits, :card_type, :stripe_id, :stripe_token, :user_id
end
