class CreateWithdrawRequests < ActiveRecord::Migration
  def change
    create_table :withdraw_requests do |t|
      t.integer :user_id
      t.decimal :amount
      t.string :status
      t.timestamps
    end
  end
end
