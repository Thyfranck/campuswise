class StaticController < ApplicationController

  def home
    session.delete(:school_id) unless current_user
    @recent_books = Book.order("created_at DESC")
    
    @school_images = SchoolImage.order("created_at desc")

    respond_to do |format|
      format.html
    end
  end

  def public_find_books
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


  def public_search
    @books = current_school.books
    @books = @books.search_for(params[:search]).paginate(:page => params[:page], :per_page => 6)
    respond_to do |format|
      format.html
    end
  end

  def show_public
    @book = Book.find(params[:id])
  end
end
