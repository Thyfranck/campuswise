# book_id => owner book id
#user_id => requester user id

class Exchange < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :accepted
  belongs_to :book
  belongs_to :user
  has_one :dashboard_notification

  def destroy_other_pending_requests
    book = self.book_id
    borrower = self.user_id
    @other_pending_requests = Exchange.where("book_id = ? and user_id != ?", book, borrower)
    @other_pending_requests.each {|e| e.destroy} if @other_pending_requests.any?
  end
end
