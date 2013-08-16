class RemoveDebitFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :debit
  end

  def down
    add_column :users, :debit, :string
  end
end
