class RenameColumnNameBooks < ActiveRecord::Migration
  def change
    rename_column :books, :price, :purchase_price
  end
end
