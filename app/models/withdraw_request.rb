class WithdrawRequest < ActiveRecord::Base
  attr_accessible :amount, :user_id

  belongs_to :user
  has_many :dashboard_notifications, :as => :dashboardable
  has_one :transaction, :as => :transactable

  validates :amount, :presence => true, :numericality => true

  STATUS = {
    :paid => "PAID",
    :rejected => "REJECTED",
    :pending => "PENDING"
  }

  scope :paid, where(:status => STATUS[:paid])
  scope :pending, where(:status => STATUS[:pending])

  before_create :check_credit, :set_status,
    :check_if_has_pending_request,
    :check_if_has_payment_method
              
  after_create :notify_admin
  after_update :make_transaction_history

  def make_transaction_history
    if self.status_was == WithdrawRequest::STATUS[:pending] and self.status == WithdrawRequest::STATUS[:paid]
      transaction = self.build_transaction(:user_id => self.user.id,
        :description => "Withdrawed amount of $#{self.amount} at #{self.updated_at.to_date}")
      transaction.save
    end
  end

  def check_credit
    if self.user.credit.present?
      if self.amount.to_f > self.user.credit.to_f
        errors.add(:amount, "exceeds your total credit")
        return false
      else
        return true
      end
    else
      errors[:base] << "Your credit is empty"
      return false
    end
  end

  def check_if_has_payment_method
    if self.user.payment_method.present?
      return true
    else
      errors[:base] << "Payment method not specified yet."
      return false
    end
  end

  def set_status
    self.status = WithdrawRequest::STATUS[:pending]
  end

  def check_if_has_pending_request
    if self.user.withdraw_requests.where(:status => WithdrawRequest::STATUS[:pending]).present?
      errors[:base] << "You already have a request that is pending. Please wait until it is processed."
      return false
    end
  end

  def notify_admin
    @notification = self.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "<a href='/admin/users/#{self.user.id}'>#{self.user.email}</a> wants to withdraw amount of : $#{self.amount.to_f}"
    )
    @notification.save
  end
end
