class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :user_id
      t.integer :transactable_id
      t.string :transactable_type
      t.text :description

      t.timestamps
    end
  end
end
