class RemoveExchangeIdFromDashboardNotifications < ActiveRecord::Migration
  def up
    remove_column :dashboard_notifications, :exchange_id
  end

  def down
    add_column :dashboard_notifications, :exchange_id, :integer
  end
end
