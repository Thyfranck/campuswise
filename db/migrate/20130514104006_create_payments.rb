class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :exchange_id
      t.decimal :payment_amount, :default => 0.0
      t.string :status
      t.string :charge_id

      t.timestamps
    end
  end
end
