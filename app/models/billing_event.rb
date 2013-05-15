class BillingEvent < ActiveRecord::Base
  attr_accessible :event_type, :payment_id, :response, :user_id

  belongs_to :user
  belongs_to :payment

  after_create :update_payment
#  after_create :send_notification_email


  private

  def update_payment
    if self.event_type == "charge.succeeded"
      payment.status = Payment::STATUS[:paid]
      payment.save
    else
      payment.status = Payment::STATUS[:failed]
      payment.save
      payment.business.payment_complete = false
      payment.business.step_in = 5
      payment.business.save(:validate => false)
    end
  end

#  def send_notification_email
#    Notification.charge_succeeded(self.id).deliver if self.event_type == "charge.succeeded"
#    Notification.charge_failed(self.id).deliver if self.event_type == "charge.failed"
#  end
end
