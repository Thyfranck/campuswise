class School < ActiveRecord::Base
  has_many :users

  attr_accessible :name, :email_postfix, :image
end
