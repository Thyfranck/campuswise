class AddSomeFieldsToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :amount, :decimal
    add_column :exchanges, :package, :string
    add_column :exchanges, :duration, :integer
    add_column :exchanges, :starting_date, :datetime
    add_column :exchanges, :ending_date, :datetime
  end
end
