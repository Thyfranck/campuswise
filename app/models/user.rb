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
  validates :email, :format =>  { :with => /^[\w\.\+-]{1,}\@([\da-zA-Z-]{1,}\.){1,}[\da-zA-Z-]{2,6}$/ }
  validates :name, :presence => true
  validates :phone, :presence => true
  validates_length_of :password, :minimum => 6, :if => :password
  validates_confirmation_of :password, :if => :password

  after_create :send_sms_verification

  def already_borrowed_this_book(book)
    self.exchanges.find_by_book_id_and_user_id_and_accepted(book, self.id, true)
  end

  def already_sent_request(book)
    self.exchanges.find_by_book_id_and_user_id_and_accepted(book, self.id, false)
  end

  def set_phone_verification
    token = generate_unique_token
    self.phone_verification = token.slice(2,6)
  end

  def send_sms_verification
    @to = self.phone
    @body = "Thank you for registering. Please enter this code #{self.phone_verification} -Campuswise"
    @from = "(407)641-1128"
    TwilioRequest.send_verification_code(@from, @to, @body)
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
end
