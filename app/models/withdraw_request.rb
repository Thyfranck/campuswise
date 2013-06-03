class WithdrawRequest < ActiveRecord::Base
  attr_accessible :amount, :user_id

  belongs_to :user

  validates :amount, :presence => true, :numericality => true

  STATUS = {
    :paid => "PAID",
    :rejected => "REJECTED",
    :pending => "PENDING"
  }

  before_create :check_balance, :set_status
  after_create :notify_admin

  def check_balance
    if self.user.balance.present?
    if self.amount > self.user.balance
      errors.add(:amount, "exceeds your total balance")
      return false
    else
      return true
    end
    else
      errors[:base] << "Your balance is empty"
      return false
    end
  end

  def set_status
    self.status = WithdrawRequest::STATUS[:pending]
  end

  def notify_admin
    @notification = DashboardNotification.new(
      :admin_user_id => AdminUser.first.id,
      :content => "<a href='/admin/users/#{self.user.id}'>#{self.user.email}</a> wants to withdraw amount of : $#{self.amount}"
    )
    @notification.save
  end
end
