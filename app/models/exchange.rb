# book_id => owner book id
#user_id => requester user id

class Exchange < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :status, :package, :duration,
    :starting_date, :ending_date, :amount, :counter_offer, 
    :counter_offer_last_made_by, :counter_offer_count,
    :dropped_off, :dropped_off_at, :received, :received_at,
    :owner_id, :book_title

  attr_accessor :declined, :declined_reason, :agree
  
  belongs_to :book
  belongs_to :user
  has_many :dashboard_notifications, :as => :dashboardable
  has_one :transaction, :as => :transactable
  has_many :payments

  validates :duration, :numericality => true, :unless => Proc.new{|b| b.package == "semester" or "buy"}
  validates :package, :inclusion => {:in => ["day", "week", "month", "semester", "buy"]}
#  validates :counter_offer, :allow_nil => true

  STATUS = {
    :accepted => "ACCEPTED",
    :returned => "RETURNED",
    :pending => "PENDING",
    :not_returned => "NOT-RETURNED",
    :charged => "FULL-PRICE-CHARGED",
    :charge_pending => "PENDING-FULL-PRICE-CHARGE",
    :full_charge_failed => "FAILED-FULL-PRICE-CHARGE",
    :dropped_off => "DROPPED-OFF",
    :received => "RECEIVED"
  }

  after_validation :avilable_in_date?,  :valid_duration?
  before_create :set_ending_date, :if => Proc.new{|b| b.ending_date == nil}
  before_create :compute_amount,:set_status, :set_counter_offer_maker
  before_create :check_counter_offer
  before_update :check_if_sold_book_not_returned
  
  def check_if_sold_book_not_returned
    return false if self.status == Exchange::STATUS[:returned] and self.package == "buy"
    return false if self.status == Exchange::STATUS[:not_returned] and self.package == "buy"
  end

  def check_counter_offer
    if self.amount.to_f <= self.counter_offer.to_f or self.counter_offer.to_f < 0
      errors[:base] << "Counter offer must be less than actual amount and must be greater than $1.00"
      return false 
    end if self.counter_offer.present?
  end

  scope :accepted, where(:status => STATUS[:accepted])
  scope :bought_and_completed, where("package = ? AND received = ?", "buy", Exchange::STATUS[:received])

  def valid_duration?
    unless self.package == "semester" or self.package == "buy"
      if self.duration < 1
        errors[:base] << "Invalid duration"
        return false 
      end
    end
  end

  def set_counter_offer_maker
    if self.counter_offer.present?
      self.counter_offer_last_made_by = self.user.id
    end
  end

  def destroy_other_pending_requests
    book = self.book_id
    borrower = self.user_id
    @other_pending_requests = Exchange.where("status = ? and book_id = ? and user_id != ?", Exchange::STATUS[:pending], book, borrower)
    @other_pending_requests.each {|e| e.destroy} if @other_pending_requests.any?
  end

  def set_status
    self.status = Exchange::STATUS[:pending]
  end

  def not_returned?
    self.status == Exchange::STATUS[:not_returned]
  end

  def set_ending_date
    if self.package == "buy"
      self.starting_date = nil
      self.ending_date = nil
    else
      if self.package == "semester"
        fall_semester = self.user.school.fall_semester
        spring_semester = self.user.school.spring_semester
        if fall_semester.month > spring_semester.month
          if fall_semester.month >= Date.today.month and Date.today.month >= spring_semester.month
            self.ending_date = fall_semester - 1.day
          else
            self.ending_date = spring_semester - 1.day
          end
        end

        if fall_semester.month < spring_semester.month
          if fall_semester.month <= Date.today.month and Date.today.month <= spring_semester.month
            self.ending_date = spring_semester - 1.day
          else
            self.ending_date = fall_semester - 1.day
          end
        end
      end
    end
  end

  def avilable_in_date?
    if self.package == "semester"
      return true
    elsif self.package == "buy"
      return true
    else
      if self.package == "day"
        self.ending_date = self.starting_date + self.duration.days
      elsif self.package == "week"
        self.ending_date = self.starting_date + self.duration.weeks
      elsif self.package == "month"
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
    if self.package == "day"
      rate = self.book.loan_daily
    elsif self.package == "week"
      rate = self.book.loan_weekly
    elsif self.package == "month"
      rate = self.book.loan_monthly
    elsif self.package == "semester"
      rate = self.book.loan_semester
    elsif self.package == "buy"
      rate = self.book.price
    end
    if self.package == "semester" or self.package == "buy"
      total_amount = rate
    else
      total_amount = rate * self.duration
    end
    self.amount = total_amount
  end
  
  def charge
    begin
      response = self.user.billing_setting.charge(self.amount.to_f, "Book renting charge - #{self.amount.to_f}")
      if self.payments.present?
        payment = self.payments.first
        payment.charge_id = response.id
        payment.status = Payment::STATUS[:pending]
      else
        payment = self.payments.new(:payment_amount => self.amount.to_f, :charge_id => response.id, :status => Payment::STATUS[:pending])
      end      
      if payment.save
        if self.counter_offer.present?
          if self.counter_offer_last_made_by != self.user.id
            #Notify.delay.borrower_proposal_accept(self)
          else
            return true
          end
        else
          #Notify.delay.borrower_proposal_accept(self)
        end 
      end
    rescue => e
      logger.error e.message
      self.errors.add(:base, e.message)
      self.declined = e.message
      self.destroy
      return false
    end
  end

  def other_pending_payment_present?
    book = self.book_id
    borrower = self.user_id
    @other_pending_requests = Exchange.where("book_id = ? and user_id != ?", book, borrower)
    if @other_pending_requests.present? and @other_pending_requests.each {|p| p.payment}.present?
      return true if @other_pending_requests.each {|p| p.payment.status == Payment::STATUS[:pending]}.present?
    else
      return false
    end
  end
end
