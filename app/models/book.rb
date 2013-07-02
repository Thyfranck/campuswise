class Book < ActiveRecord::Base
  attr_accessible :author, :available_from, :available, :image,:isbn,
    :loan_price, :purchase_price, :publisher, :returning_date,
    :title, :user_id, :requested, :loan_daily, :loan_weekly,
    :loan_monthly, :loan_semester, :price, :available_for

  AVAILABLE_FOR = {
    :rent => "RENT",
    :sell => "SELL",
    :both => "BOTH"
  }
  
  attr_accessor :remote_image
  validates :author, :presence => true
  validates :isbn, :presence => true
  validates :title, :presence => true
  validates :available_for, :inclusion => {:in => ["RENT", "SELL", "BOTH"]}, :if => Proc.new{|b| b.available == true}
  validates :price, :presence => true, :numericality => {:greater_than_or_equal_to => 0}, :unless => Proc.new{|b| b.requested == true or b.available == false}
  validates :loan_daily, :allow_nil => true ,:numericality => {:greater_than_or_equal_to => 0, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_weekly, :allow_nil => true , :numericality => {:greater_than_or_equal_to => 0, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_monthly, :allow_nil => true , :numericality => {:greater_than_or_equal_to => 0, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  validates :loan_semester, :allow_nil => true , :numericality => {:greater_than_or_equal_to => 0, :less_than => 100}, :unless => Proc.new{|b| b.requested == true}
  
  belongs_to :user
  has_many :exchanges

  after_validation :atleast_one_loan_rate_exsists,
    :update_availability_options,
    :update_loan_and_purchase_prices,
    :set_google_image, :check_available_date_range,
    :update_availability_dates

  mount_uploader :image, ImageUploader

  scoped_search :on => [:author, :isbn, :publisher, :title]
  scope :available_now, :conditions => {:available => true}
  scope :date_not_expired, lambda { where(["available_for = ? or returning_date > ?",Book::AVAILABLE_FOR[:sell],Time.now.to_date])}
  scope :not_my_book, lambda { |current_user| where(["user_id != ?",current_user])}

  def update_availability_dates
    if self.available == false
      self.available_from = nil
      self.returning_date = nil
    end
  end

  def update_availability_options
    unless self.requested == true
      self.available_for = nil if self.available == false
    end
  end

  def check_available_date_range
    if self.available_for == Book::AVAILABLE_FOR[:sell] or self.requested == true
      return true
    else
      if self.returning_date.present? and self.available_from.present?
        if self.returning_date < self.available_from
          errors[:base] << "Invalid date range for rent."
          return false
        end
        if self.available_from < Date.tomorrow or self.returning_date < Date.tomorrow
          errors[:base] << "'Available From' date must be start from tomorrow date."
          return false
        end
      end
    end
  end

  def check_if_requested
    self.available = false if self.requested == true
  end
  
  def update_loan_and_purchase_prices
    if !self.requested and self.available and self.available_for == Book::AVAILABLE_FOR[:sell]
      self.available_from = nil
      self.returning_date = nil
      self.loan_daily = nil
      self.loan_monthly = nil
      self.loan_semester = nil
      self.loan_weekly = nil
    end
  end

  def set_google(book_id)
    google_book = GoogleBooks.search(book_id, {}, "4.2.2.1").first
    self.title = google_book.title
    self.author = google_book.authors
    self.publisher = google_book.publisher
    self.isbn = google_book.isbn
    self.remote_image = google_book.image_link(:zoom => 1)
  end

  def set_db(id)
    @db_book = Book.find(id)
    self.title = @db_book.title
    self.author = @db_book.author
    self.image = @db_book.image
    self.publisher = @db_book.publisher
    self.isbn = @db_book.isbn
  end

  def set_google_image
    if self.image.blank?
      book = GoogleBooks.search("isbn:#{self.isbn}",{}, "4.2.2.1").first
      if book
        image_link = book.image_link(:zoom => 1)
        agent = Mechanize.new
        agent.pluggable_parser.default = Mechanize::Download
        begin
          @previous_image = File.open("tmp/books/book_#{self.user.id}.jpg").present?
          File.delete("tmp/books/book_#{self.user.id}.jpg") if @previous_image
        rescue Errno::ENOENT
        end
        agent.get(image_link).save("#{Rails.root}/tmp/books/book_#{self.user.id}.jpg")
        self.image = File.open("tmp/books/book_#{self.user.id}.jpg")
      else
        return true
      end
    end
  end

  def lended
    unless self.requested == true
      if self.exchanges.where(:status => Exchange::STATUS[:accepted]).any?
        return true
      else
        return false
      end
    end
  end

  def atleast_one_loan_rate_exsists
    unless self.requested == true
      if self.available_for == Book::AVAILABLE_FOR[:sell]
        return true
      elsif self.available == true and self.available_for != Book::AVAILABLE_FOR[:sell]
        if self.loan_daily == nil and self.loan_monthly == nil and self.loan_weekly == nil and self.loan_semester == nil
          errors[:base] << "You must specify atleast one loan rate."
          return false
        else
          return true
        end
      end
    end
  end

  def make_available
    self.available = true
    self.save
  end

  def make_unavailable
    self.available = false
    self.save
  end
end
