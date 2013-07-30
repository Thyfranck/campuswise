class ChangeContentAtTdashboardNotifications < ActiveRecord::Migration
  def change
    change_column :dashboard_notifications, :content, :text
  end
end
