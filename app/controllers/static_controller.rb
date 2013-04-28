class StaticController < ApplicationController

  def home
    session.delete(:school_id)
    
    @school_images = SchoolImage.order("created_at desc")

    respond_to do |format|
      format.html
    end
  end

  def public_find_books
    @school = School.find(params[:school_id])
    @school_images = @school.school_images.order("created_at desc")
    
    if @school_images.count < 2
      @school_images = SchoolImage.order("created_at desc").limit(5)
    end

    respond_to do |format|
      if @school.present?
        session[:school_id] = @school.id
        format.html
      else
        format.html { redirect_to root_path }
      end
    end
  end
end
