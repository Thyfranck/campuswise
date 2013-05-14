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

  def charge(amount)
    begin
      response = self.user.billing_setting.charge(amount, "Entity Formation Fee for Business name - #{self.name}")
      if self.payment.present?
        payment = self.payment
        payment.charge_id = response.id
        payment.status = Payment::STATUS[:pending]
      else
        payment = self.build_payment(:payment_amount => amount, :charge_id => response.id, :status => Payment::STATUS[:pending])
      end
      payment.save
      self.payment_complete = true
      self.charge_card = nil
      return true
    rescue => e
      logger.error e.message
      errors.add(:base, e.message)
      return false
    end
  end
end
