class SorceryCore < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :school_id,       :default => nil
      t.string :email,            :null => false  # if you use another field as a username, for example email, you can safely remove this field.
      t.string :name,             :default => nil
      t.string :phone,            :default => nil
      t.string :facebook,         :default => nil
      t.string :crypted_password, :default => nil
      t.string :salt,             :default => nil

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end