class Book < ActiveRecord::Base
  attr_accessible :author, :available_from, :available, :image,:isbn,
    :loan_price, :purchase_price, :publisher, :returning_date,
    :title, :user_id, :requested, :loan_daily, :loan_weekly, :loan_monthly, :loan_semister

  attr_accessor :remote_image
  validates :author, :presence => true
  validates :isbn, :presence => true 
  validates :title, :presence => true
  #  validates :purchase_price, :presence => false ,:numericality => {:greater_than_or_equal => 5}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_daily, :allow_nil => true ,:numericality => {:greater_than_or_equal_to => 5, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_weekly, :allow_nil => true , :numericality => {:greater_than_or_equal_to => 5, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_monthly, :allow_nil => true , :numericality => {:greater_than_or_equal_to => 5, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_semister, :allow_nil => true , :numericality => {:greater_than_or_equal_to => 5, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  
  belongs_to :user
  has_many :exchanges

  before_save :atleast_one_loan_rate_exsists

  mount_uploader :image, ImageUploader

  scoped_search :on => [:author, :isbn, :publisher, :title]
  scope :available_now, :conditions => {:available => true}
  scope :not_my_book, lambda { |current_user| where(["user_id != ?",current_user])}

  def set_google(book_id)
    google_book = GoogleBooks.search(book_id).first
    self.title = google_book.title
    self.author = google_book.authors
    self.publisher = google_book.publisher
    self.isbn = google_book.isbn
    self.remote_image = google_book.image_link(:zoom => 1)
  end

  def set_google_image(remote_url, current_user)
    agent = Mechanize.new
    agent.pluggable_parser.default = Mechanize::Download
    agent.get(remote_url).save("#{Rails.root}/tmp/books/book_#{current_user.id}.jpg")
    self.image = File.open("tmp/books/book_#{current_user.id}.jpg")
  end

  def lended
    if self.exchanges.where(:accepted => true).any?
      return true
    else
      return false
    end
  end

  def atleast_one_loan_rate_exsists
    if self.loan_daily == nil and self.loan_monthly == nil and self.loan_weekly == nil and self.loan_semister == nil
      errors[:base] << "You must specify atleast one loan rate."
      return false
    else
      return true
    end
  end
end
