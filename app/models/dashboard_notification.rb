class DashboardNotification < ActiveRecord::Base
  attr_accessible :user_id, :content, :exchange_id

  belongs_to :user
  belongs_to :exchange
end
