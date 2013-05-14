class CreateBillingEvents < ActiveRecord::Migration
  def change
    create_table :billing_events do |t|
      t.string :event_type
      t.text :response
      t.integer :user_id
      t.integer :payment_id

      t.timestamps
    end
  end
end
