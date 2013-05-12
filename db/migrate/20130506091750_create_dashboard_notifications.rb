class CreateDashboardNotifications < ActiveRecord::Migration
  def change
    create_table :dashboard_notifications do |t|
      t.integer :user_id
      t.integer :exchange_id
      t.string :content
      t.timestamps
    end
  end
end
