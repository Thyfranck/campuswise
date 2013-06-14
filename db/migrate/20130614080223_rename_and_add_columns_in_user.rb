class RenameAndAddColumnsInUser < ActiveRecord::Migration
  def change
    rename_column :users, :balance, :credit
    add_column :users, :debit, :decimal, :precision => 10, :scale => 2
  end
end
