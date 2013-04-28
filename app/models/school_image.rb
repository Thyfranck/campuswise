class SchoolImage < ActiveRecord::Base
  mount_uploader :image, SchoolImageUploader

  attr_accessible :image, :school_id

  belongs_to :school
end
