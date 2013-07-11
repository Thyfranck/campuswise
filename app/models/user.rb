class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :school
  has_many :books, :dependent => :destroy
  has_many :exchanges
  has_many :dashboard_notifications, :dependent => :destroy
  has_one :billing_setting, :dependent => :destroy
  has_many :billing_events
  has_many :payment_methods, :dependent => :destroy
  has_many :withdraw_requests
  has_many :transactions
  
  def accepted_exchanges
    self.exchanges.where(:status => Exchange::STATUS[:accepted])
  end

  def pending_exchanges
    self.exchanges.where(:status => Exchange::STATUS[:pending])
  end
  
  has_many :not_returned_exchanges, :through => :books, :conditions => "status = '#{Exchange::STATUS[:not_returned]}'" ,:source => :exchanges #for request receiver(book owner)
  has_many :pending_reverse_exchanges, :through => :books, :conditions => "status = '#{Exchange::STATUS[:pending]}'" ,:source => :exchanges #for request receiver(book owner)
  has_many :accepted_reverse_exchanges, :through => :books, :conditions => "status = '#{Exchange::STATUS[:accepted]}'" ,:source => :exchanges #for request receiver(book owner)

  attr_accessor :current_password

  attr_accessible :email, :password, :password_confirmation, :current_password,
    :facebook, :phone_verification, :phone_verified,
    :school_id, :phone, :credit, :debit, :first_name, :last_name

  validates_uniqueness_of :email
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true

  validates_length_of :password, :minimum => 6, :if => :password
  validates_confirmation_of :password, :if => :password
  validates :email, :format =>  { :with => /^[\w\.\+-]{1,}\@([\da-zA-Z-]{1,}\.){1,}[\da-zA-Z-]{2,6}$/ }
  
  before_update :check_if_phone_changed
  before_update :check_if_email_changed

  before_create :setup_activation
  after_create :send_activation_needed_email!

  def name
    "#{first_name} #{last_name}"
  end

  def balance
    self.credit.to_f - self.debit.to_f
  end

  def check_if_email_changed
    if self.email_changed?
      errors[:base] << "Not allowed to update email."
      return false
    end
  end

  def make_email_format
    self.email = self.email + "@" +self.school.email_postfix 
  end

  def already_borrowed_this_book(book)
    self.exchanges.find_by_book_id_and_user_id_and_status(book, self.id, Exchange::STATUS[:accepted])
  end

  def already_sent_request(book)
    self.exchanges.find_by_book_id_and_user_id_and_status(book, self.id,  Exchange::STATUS[:pending])
  end

  def eligiable_to_borrow(book)
    if self.already_borrowed_this_book(book) == true or self.already_sent_request(book) == true and book.available == false
      return false
    else
      return true
    end
  end

  def not_eligiable_to_borrow_or_buy(book)
    if self.already_borrowed_this_book(book) == true or
        self.already_sent_request(book) == true or
        book.available == false or
        book.user.id == self.id
      return true
    else
      return false
    end
  end

  def set_phone_verification
    token = generate_unique_token
    self.phone_verified = "pending"
    self.phone_verification = token.slice(2,6)
  end

  def send_sms_verification
    if self.phone_verified == "pending"
      if self.phone_verification.blank?
        self.set_phone_verification
        self.save
      end
      @to = self.phone
      @body = "Please enter this code #{self.phone_verification} -Campuswise"
      TwilioRequest.send_sms(@body, @to)
    else
      return true
    end
  end

  def check_if_phone_changed
    if self.phone_changed? and self.phone_verified == "verified"
      self.set_phone_verification
      self.send_sms_verification
      return true
    else
      return true
    end
  end

  def verify_phone
    self.phone_verified = "verified"
    self.phone_verification = nil
    if self.save
      return true
    else
      return false
    end
  end

  private  
  def generate_unique_token
    Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def self.authenticate_without_active_check(*credentials)
    prevent_check = self.sorcery_config.before_authenticate.delete(:prevent_non_active_login)
    user = self.authenticate(*credentials)
    self.sorcery_config.before_authenticate << prevent_check if prevent_check
    return user
  end
end
