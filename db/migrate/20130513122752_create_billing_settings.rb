class CreateBillingSettings < ActiveRecord::Migration
  def change
    create_table :billing_settings do |t|
      t.string :card_holder_name
      t.string :card_expiry_date
      t.string :card_last_four_digits
      t.string :card_type
      t.string :stripe_id
      t.string :user_id
      t.string :stripe_token

      t.timestamps
    end
  end
end
