class AddAmountToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :amount, :decimal, :precision => 10, :scale => 2
  end
end
