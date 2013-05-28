class DashboardNotification < ActiveRecord::Base
  attr_accessible :user_id, :content, :exchange_id, :admin_user_id

  belongs_to :user
  belongs_to :admin_user
  belongs_to :exchange
end
