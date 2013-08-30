class Transaction < ActiveRecord::Base
  attr_accessible :description, :transactable_id, :transactable_type,
    :user_id, :credit, :debit, :amount, :status

  STATUS = {
    :pending => "PENDING",
    :complete => "COMPLETE"
  }
  belongs_to :user
  belongs_to :transactable, :polymorphic => true

  after_update :update_users_current_balance

  def update_users_current_balance
    if self.status_was == Transaction::STATUS[:pending] and self.status == Transaction::STATUS[:complete]
      self.user.current_balance = self.amount
      self.user.save
    end
  end

  def pending?
    self.status == Transaction::STATUS[:pending]
  end

  def complete?
    self.status == Transaction::STATUS[:complete]
  end
end
