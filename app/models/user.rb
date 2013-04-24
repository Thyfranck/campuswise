class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :school

  attr_accessible :name, :email, :password, :password_confirmation, :facebook, :school_id, :phone
  validates_uniqueness_of :email
  validates_length_of :password, :minimum => 3, :message => "must be at least 3 characters long", :if => :password
  validates_confirmation_of :password, :message => "should match confirmation", :if => :password
end
