class BillingEvent < ActiveRecord::Base
  attr_accessible :event_type, :payment_id, :response, :user_id
end
