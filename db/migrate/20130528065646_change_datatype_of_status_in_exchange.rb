class ChangeDatatypeOfStatusInExchange < ActiveRecord::Migration
  def change
    change_column :exchanges, :status, :string
  end
end
