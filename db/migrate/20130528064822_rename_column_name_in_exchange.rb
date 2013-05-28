class RenameColumnNameInExchange < ActiveRecord::Migration
  def change
    rename_column :exchanges, :accepted, :status
  end
end
