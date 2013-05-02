class Book < ActiveRecord::Base
  attr_accessible :author, :available_from, :available, :image, :remote_image_url ,:isbn, :loan_price, :price, :publisher, :returning_date, :title, :user_id

  validates :author, :presence => true
  validates :isbn, :presence => true 
  validates :title, :presence => true 
  validates :publisher, :presence => true
  
  belongs_to :user

  mount_uploader :image, ImageUploader

  scoped_search :on => [:author, :isbn, :publisher, :title]
end
