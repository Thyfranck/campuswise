class AddDashboardableToDashboardNotifications < ActiveRecord::Migration
  def change
    add_column :dashboard_notifications, :dashboardable_id, :integer
    add_column :dashboard_notifications, :dashboardable_type, :string
  end
end
