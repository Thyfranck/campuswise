class BillingSetting < ActiveRecord::Base
  attr_accessible :card_expiry_date, :card_holder_name,
    :card_last_four_digits, :card_type,
    :stripe_id, :stripe_token, :user_id
  
  attr_accessor :stripe_token

  belongs_to :user

  before_save :create_or_update_stripe_customer

  before_destroy :delete_stripe_customer

  def create_or_update_stripe_customer
    if stripe_token.present?
      if stripe_id.nil?
        customer = Stripe::Customer.create(
          :description => self.user.name,
          :email => self.user.email,
          :card => stripe_token
        )
        update_information(customer)
      else
        customer = Stripe::Customer.retrieve(stripe_id)
        customer.card = stripe_token
        customer.save
        update_information(customer)
      end
      self.stripe_token = nil
    end
  end

  def update_information(customer)
    self.card_last_four_digits = customer.active_card.last4
    self.card_holder_name = customer.active_card.name
    self.card_type = customer.active_card.type
    card_expiry_date_string = "#{customer.active_card.exp_year}-#{customer.active_card.exp_month}-01"
    self.card_expiry_date = Date.parse(card_expiry_date_string).end_of_month
    self.stripe_id = customer.id
  end

  def charge(amount, memo)
    response = Stripe::Charge.create(
      :amount => (amount.to_f * 100.0).to_i,
      :currency => "usd",
      :customer => customer,
      :description => "#{memo}")
    return response
  end

  def customer
    @customer ||= Stripe::Customer.retrieve(self.stripe_id) rescue nil
  end

  def delete_stripe_customer
    customer.delete
  end
end
