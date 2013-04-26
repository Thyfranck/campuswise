class School < ActiveRecord::Base
  attr_accessible :name, :email_postfix, :image

  has_many :users
  has_many :books, :through => :users
end
