# book_id => owner book id
#user_id => requester user id

class Exchange < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :accepted, :package, :duration,
    :starting_date, :ending_date, :amount

  belongs_to :book
  belongs_to :user
  has_many :dashboard_notifications
  has_one :payment, :dependent => :destroy

  validates :duration, :numericality => true, :unless => Proc.new{|b| b.package == "semister"}
  validates :package, :inclusion => {:in => ["daily", "weekly", "monthly", "semister"]}

  def destroy_other_pending_requests
    book = self.book_id
    borrower = self.user_id
    @other_pending_requests = Exchange.where("book_id = ? and user_id != ?", book, borrower)
    @other_pending_requests.each {|e| e.destroy} if @other_pending_requests.any?
  end

  before_create :compute_amount, :avilable_in_date?

  def avilable_in_date?
    if self.package == "semister"
      return true
    else
      if self.package == "daily"
        self.ending_date = self.starting_date + self.duration.days
      elsif self.package == "weekly"
        self.ending_date = self.starting_date + self.duration.weeks
      elsif self.package == "monthly"
        self.ending_date = self.starting_date + self.duration.months
      end
      if self.starting_date >= self.book.available_from and self.ending_date <= self.book.returning_date
        return true
      else
        errors[:base] << "The book is not available in that requested time."
        return false
      end
    end
  end
  
  def compute_amount
    if self.package == "daily"
      rate = self.book.loan_daily
    elsif self.package == "weekly"
      rate = self.book.loan_weekly
    elsif self.package == "monthly"
      rate = self.book.loan_monthly
    elsif self.package == "semister"
      rate = self.book.loan_semister
    end
    if self.package == "semister"
      total_amount = rate
    else
      total_amount = rate * self.duration
    end
    self.amount = total_amount
  end
  
  def charge
    begin
      response = self.user.billing_setting.charge(self.amount, "Book renting charge - #{self.amount}")
      if self.payment.present?
        payment = self.payment
        payment.charge_id = response.id
        payment.status = Payment::STATUS[:pending]
      else
        payment = self.build_payment(:payment_amount => self.amount, :charge_id => response.id, :status => Payment::STATUS[:pending])
      end
      payment.save
      return true
    rescue => e
      logger.error e.message
      errors.add(:base, e.message)
      return false
    end
  end
end
