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

  attr_accessible :name, :email, :password, :password_confirmation, :facebook, 
    :school_id, :phone
  
  validates_uniqueness_of :email
  validates :email, :format =>  { :with => /^[\w\.\+-]{1,}\@([\da-zA-Z-]{1,}\.){1,}[\da-zA-Z-]{2,6}$/ }
  validates :name, :presence => true
  validates :phone, :presence => true
  validates_length_of :password, :minimum => 6, :if => :password
  validates_confirmation_of :password, :if => :password

  def already_borrowed_this_book(book)
    self.exchanges.find_by_book_id_and_user_id_and_accepted(book, self.id, true)
  end

  def already_sent_request(book)
    self.exchanges.find_by_book_id_and_user_id_and_accepted(book, self.id, false)
  end
end
