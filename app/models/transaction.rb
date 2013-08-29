class Transaction < ActiveRecord::Base
  attr_accessible :description, :transactable_id, :transactable_type,
    :user_id, :credit, :debit, :amount, :status

  STATUS = {
    :pending => "PENDING",
    :complete => "COMPLETE"
  }
  belongs_to :user
  belongs_to :transactable, :polymorphic => true

  after_save :update_users_current_balance

  def update_users_current_balance
    if self.user.update_attribute(:current_balance, self.amount)
      return true
    else
      return false
    end if self.status == Transaction::STATUS[:completed]
  end

  def credit_type?
    self.credit != 0.0 and self.debit == 0.0
  end

  def pending?
    self.status == Transaction::STATUS[:pending]
  end

  def complete?
    self.status == Transaction::STATUS[:complete]
  end
end
