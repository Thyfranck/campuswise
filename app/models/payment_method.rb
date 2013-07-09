class PaymentMethod < ActiveRecord::Base
  attr_accessible :user_id, :account_holder_name,
    :account_number, :bank_name,:bank_branch,
    :credit_card_type, :card_number, :payment_method_type,
    :paypal
  belongs_to :user

  TYPE = {
    :bank => "Bank Account",
    :card => "Credit Card",
    :paypal => "Paypal"
  }

  validates :payment_method_type, :presence => true
  validates :account_holder_name, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}
  validates :account_number, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}
  validates :bank_name, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}
  validates :bank_branch, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:bank]}

  validates :credit_card_type, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:card]}
  validates :card_number, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:card]}
  validates :paypal, :presence => true, :if => Proc.new{|b| b.payment_method_type == PaymentMethod::TYPE[:paypal]}

  before_save :check_user_payment_methods

  def check_user_payment_methods
    return false if self.user.payment_methods.count > 3
  end

end
