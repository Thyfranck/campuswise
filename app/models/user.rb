class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :school
  has_many :books, :dependent => :destroy
  has_many :exchanges
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
    self.exchanges.find_by_book_id_and_user_id(book, self.id)
  end
end
