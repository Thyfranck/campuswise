# book_id => owner book id
#user_id => requester user id

class Exchange < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :accepted
  
  belongs_to :book
  belongs_to :user
  has_one :dashboard_notification
end
