class AddPhoneVerificationToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone_verification, :string
    add_column :users, :phone_verified, :string, :default => "pending"
  end
end
