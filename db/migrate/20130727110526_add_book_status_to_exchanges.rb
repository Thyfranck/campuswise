class AddBookStatusToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :dropped_off, :string
    add_column :exchanges, :dropped_off_at, :datetime
    add_column :exchanges, :received, :string
    add_column :exchanges, :received_at, :datetime
  end
end
