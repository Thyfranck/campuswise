class AddCounterOfferCountToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :counter_offer_count, :integer, :default => 0
  end
end
