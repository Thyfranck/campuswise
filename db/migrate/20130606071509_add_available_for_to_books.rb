class AddAvailableForToBooks < ActiveRecord::Migration
  def change
    add_column :books, :available_for, :string
  end
end
