class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.integer :user_id
      t.string :payment_method_type
      t.string :bank_name
      t.string :account_holder_name
      t.string :account_number
      t.string :credit_card_type
      t.string :card_number
      t.timestamps
    end
  end
end
