class School < ActiveRecord::Base
  attr_accessible :name, :email_postfix, :image

  has_many :users, :dependent => :destroy
  has_many :books, :through => :users
end
