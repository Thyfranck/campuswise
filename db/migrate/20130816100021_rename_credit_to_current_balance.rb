class RenameCreditToCurrentBalance < ActiveRecord::Migration
  def change
    rename_column :users, :credit, :current_balance
  end
end
