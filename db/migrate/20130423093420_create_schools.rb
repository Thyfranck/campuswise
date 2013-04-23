class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name
      t.string :email_postfix
      t.string :image
      t.timestamps
    end
  end
end