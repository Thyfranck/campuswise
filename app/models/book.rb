class Book < ActiveRecord::Base
  attr_accessible :author, :available_from, :available, :image, :isbn, :loan_price, :price, :publisher, :returning_date, :title, :user_id

  belongs_to :user

  mount_uploader :image, ImageUploader
end
