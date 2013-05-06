class CreateExchanges < ActiveRecord::Migration
  def change
    create_table :exchanges do |t|
      t.integer :book_id
      t.integer :user_id
      t.boolean :accepted, :default => false
      t.timestamps
    end
  end
end
