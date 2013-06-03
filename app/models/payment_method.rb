class PaymentMethod < ActiveRecord::Base
  attr_accessible :user_id, :account_holder_name, :account_number, :bank_name, :credit_card_type, :card_number, :payment_method_type
  belongs_to :user

  TYPE = {
    :bank => "Bank Account",
    :card => "Credit Card"
  }

  validates :payment_method_type, :presence => true
  validates :account_holder_name, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}
  validates :account_number, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}
  validates :bank_name, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}

  validates :credit_card_type, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:card]}
  validates :credit_card_number, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:card]}

end
