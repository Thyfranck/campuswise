class AddPaymentMethodToWithdrawRequest < ActiveRecord::Migration
  def change
    add_column :withdraw_requests, :payment_method, :string
  end
end
