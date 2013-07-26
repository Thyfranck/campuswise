class AddSeenToDashboardNotifications < ActiveRecord::Migration
  def change
    add_column :dashboard_notifications, :seen, :boolean, :default => false
  end
end
