class AddRequestedToBooks < ActiveRecord::Migration
  def change
    add_column :books, :requested, :boolean, :default => false
  end
end
