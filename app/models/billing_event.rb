class BillingEvent < ActiveRecord::Base
  attr_accessible :event_type, :payment_id, :response, :user_id

  belongs_to :user
  belongs_to :payment

  after_create :update_payment


  private

  def update_payment
    if self.event_type == "charge.succeeded"
      payment.status = Payment::STATUS[:paid]
      payment.save
    else
      payment.status = Payment::STATUS[:failed]
      payment.save
    end
  end
end
