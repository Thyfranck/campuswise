class Book < ActiveRecord::Base
  attr_accessible :author, :available_from, :available, :image,:isbn, :loan_price, :price, :publisher, :returning_date, :title, :user_id

  attr_accessor :remote_image
  validates :author, :presence => true
  validates :isbn, :presence => true 
  validates :title, :presence => true 
  
  belongs_to :user

  mount_uploader :image, ImageUploader

  scoped_search :on => [:author, :isbn, :publisher, :title]

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
end
