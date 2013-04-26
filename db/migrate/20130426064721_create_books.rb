class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.integer :user_id
      t.string :title
      t.string :image
      t.string :author
      t.string :isbn
      t.string :publisher
      t.decimal :price
      t.decimal :loan_price
      t.boolean :available
      t.date :available_from
      t.date :returning_date

      t.timestamps
    end
  end
end
