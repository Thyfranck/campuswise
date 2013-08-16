class AddSomeFieldToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :debit, :float
    add_column :transactions, :credit, :float
  end
end
