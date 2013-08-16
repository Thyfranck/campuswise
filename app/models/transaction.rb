class Transaction < ActiveRecord::Base
  attr_accessible :description, :transactable_id, :transactable_type, :user_id, :credit, :debit, :amount

  belongs_to :user
  belongs_to :transactable, :polymorphic => true

  after_save :update_users_current_balance

  def update_users_current_balance
    if self.user.update_attribute(:current_balance, self.amount)
      return true
    else
      return false
    end
  end
end
