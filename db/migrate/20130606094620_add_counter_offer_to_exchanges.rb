class AddCounterOfferToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :counter_offer, :decimal
    add_column :exchanges, :counter_offer_last_made_by, :integer
  end
end
