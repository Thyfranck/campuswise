class RemoveImageFromSchools < ActiveRecord::Migration
  def up
    remove_column :schools, :image
  end

  def down
    add_column :schools, :image, :string
  end
end
