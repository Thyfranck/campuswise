class School < ActiveRecord::Base
  attr_accessible :name, :email_postfix, :image, :spring_semester, :fall_semester

  has_many :users,          :dependent => :destroy
  has_many :books,          :through => :users
  has_many :school_images,  :dependent => :destroy

  before_save :make_date

  def make_date
    @spring_semester = Date.new(Time.now.year,self.spring_semester.month,self.spring_semester.day)
    @fall_semester = Date.new(Time.now.year,self.fall_semester.month,self.fall_semester.day)
    self.spring_semester = @spring_semester
    self.fall_semester = @fall_semester
  end

end
