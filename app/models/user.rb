class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :school
  has_many :books, :dependent => :destroy
  has_many :exchanges
  def accepted_exchanges
    self.exchanges.where(:accepted => true)
  end

  def pending_exchanges
    self.exchanges.where(:accepted => false)
  end

  has_many :pending_reverse_exchanges, :through => :books, :conditions => "accepted = false" ,:source => :exchanges #for request receiver(book owner)
  has_many :accepted_reverse_exchanges, :through => :books, :conditions => "accepted = true" ,:source => :exchanges #for request receiver(book owner)

  has_many :dashboard_notifications

  attr_accessible :name, :email, :password, :password_confirmation, 
    :facebook, :phone_verification, :phone_verified,
    :school_id, :phone
  
  validates_uniqueness_of :email
  
  validates :name, :presence => true
  validates :phone, :presence => true
  validates_length_of :password, :minimum => 6, :if => :password
  validates_confirmation_of :password, :if => :password
  validates :email, :format =>  { :with => /^[\w\.\+-]{1,}\@([\da-zA-Z-]{1,}\.){1,}[\da-zA-Z-]{2,6}$/ }
  after_create :send_sms_verification
  #  before_update :check_if_phone_changed
  #  after_update :send_sms_verification

  def make_email_format
    self.email = self.email + "@" +self.school.email_postfix 
  end

  def already_borrowed_this_book(book)
    self.exchanges.find_by_book_id_and_user_id_and_accepted(book, self.id, true)
  end

  def already_sent_request(book)
    self.exchanges.find_by_book_id_and_user_id_and_accepted(book, self.id, false)
  end

  def set_phone_verification
    token = generate_unique_token
    self.phone_verified = "pending"
    self.phone_verification = token.slice(2,6)
  end

  def send_sms_verification
    if self.phone_verified == "pending"
      @to = self.phone
      @body = "Please enter this code #{self.phone_verification} -Campuswise"
      @from = "(972)885-5027"
      TwilioRequest.send_sms(@from, @to, @body)
    else
      return true
    end
  end

  def check_if_phone_changed
    if self.phone_changed?
      self.set_phone_verification
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
