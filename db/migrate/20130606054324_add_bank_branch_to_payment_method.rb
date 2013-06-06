class AddBankBranchToPaymentMethod < ActiveRecord::Migration
  def change
    add_column :payment_methods, :bank_branch, :string
  end
end
