class StaticController < ApplicationController

  before_filter :redirect_if_one_school_present, :only => [:home]

  def home
    session.delete(:school_id) unless current_user
    @recent_books = Book.order("created_at DESC")
    @school_images = SchoolImage.order("created_at desc")
  end

  def school_home
    @recent_books = Book.order("created_at DESC")
    if current_school
      @school = current_school
    else
      @school = School.find(params[:school_id])
    end
    @school_images = @school.school_images.order("created_at desc")
    if @school_images.count < 2
      @school_images = SchoolImage.order("created_at desc").limit(5)
    end

    respond_to do |format|
      if @school.present?
        session[:school_id] = @school.id
        format.html
        format.js
      else
        format.html { redirect_to root_path }
      end
    end
  end

  def privacy_policy
  end

  def terms
  end

  def contact_us
    
  end

  private

  def redirect_if_one_school_present
    redirect_to school_home_path(:school_id => School.first.id) if School.count == 1
  end


end
