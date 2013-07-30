class AfterReturnAddSomeFieldsToExchanges < ActiveRecord::Migration
  def change
    add_column :exchanges, :owner_id, :integer
    add_column :exchanges, :book_title, :text
  end
end
