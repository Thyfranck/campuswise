class DashboardNotification < ActiveRecord::Base
  attr_accessible :user_id, :content, :admin_user_id, :seen

  belongs_to :user
  belongs_to :admin_user
  belongs_to :dashboardable, :polymorphic => true
end
