class CreateSchoolImages < ActiveRecord::Migration
  def change
    create_table :school_images do |t|
      t.integer :school_id
      t.string :image

      t.timestamps
    end
  end
end
