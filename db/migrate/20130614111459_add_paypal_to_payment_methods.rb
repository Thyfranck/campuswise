class AddPaypalToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :paypal, :string
  end
end
