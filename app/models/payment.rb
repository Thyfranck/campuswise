class Payment < ActiveRecord::Base
  attr_accessible :charge_id, :exchange_id, :payment_amount, :status
end
