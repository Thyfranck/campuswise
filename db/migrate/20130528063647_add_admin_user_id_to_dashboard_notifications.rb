class AddAdminUserIdToDashboardNotifications < ActiveRecord::Migration
  def change
    add_column :dashboard_notifications, :admin_user_id, :integer
  end
end
