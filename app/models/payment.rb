class Payment < ActiveRecord::Base
  attr_accessible :charge_id, :exchange_id, :payment_amount, :status

  belongs_to :exchange
  has_many :billing_events, :dependent => :destroy

  STATUS = {
    :paid => "PAID",
    :failed => "FAILED",
    :pending => "PENDING"
  }
end
