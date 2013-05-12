class BooksController < ApplicationController
  before_filter :require_login, :except => [:show, :available]

  layout "dashboard"

  def index
    @books = current_user.books.where(:requested => false).paginate(:page => params[:page], :per_page => 6)
  end

  def new
    @book = current_user.books.new
    if params[:google_book_id]
      @book.set_google(params[:google_book_id])
    end
    if params[:request]
      @requested_book = true
    end
  end

  def create
    unless params[:search] == "Search"
      @book = current_user.books.new(params[:book])
      unless params[:remote_url].blank?
        @book.set_google_image(params[:remote_url], current_user)
      end
      respond_to do |format|
        if @book.save
          unless params[:remote_url].blank?
            File.delete("tmp/books/book_#{current_user.id}.jpg")
          end
          format.html {redirect_to books_path}
          flash[:notice] = "Request Completed"
        else
          format.html {render :action => 'new'}
        end
      end
    else
      redirect_to search_path(:value => params[:value])
    end
  end

  def show
    @book = Book.find(params[:id])
    render :layout => "application", :template => "books/public_view" if current_user.blank?
  end

  def edit
    @book = Book.find(params[:id])
    respond_to do |format|
      if @book.lended
        format.html {redirect_to book_path(@book)}
      else
        format.html
      end
    end  
  end

  def update
    @book= Book.find(params[:id])
    respond_to do |format|
      unless @book.lended == true
        @book.update_attributes(params[:book])
        format.html {redirect_to books_path}
        flash[:notice] = "Request Completed"
      else
        format.html {render :action => 'edit'}
      end
    end
  end

  def destroy
    @book = Book.find(params[:id])
    respond_to do |format|
      if @book.destroy
        format.html {redirect_to books_path}
        flash[:notice] = "Request Completed"
      else
        format.html {redirect_to user_path(current_user)}
        flash[:alert] = "Error Occured"
      end
    end
  end

  def search
    if params[:book_page] and params[:next]
      @book_page = params[:book_page].to_i + 1
    elsif params[:book_page] and params[:previous] and params[:book_page].to_i > 1
      @book_page = params[:book_page].to_i - 1
    else
      @book_page = 1
    end
    @books = GoogleBooks.search(params[:value], {:count => 10, :page => (@book_page or 1) })
    @search_result = @books.map {|book| { :image => book.image_link(:zoom => 1),
        :publisher => book.publisher,
        :title => book.title,
        :authors => book.authors,
        :isbn => book.isbn
      }}
    respond_to do |format|
      format.json { render :json => @search_result }
      format.html
    end
  end

  def show_search
    @book = GoogleBooks.search(params[:id]).first
    respond_to do |format|
      format.html
    end
  end

  def available
    @books = current_school.books.available_now
    @books = @books.not_my_book(current_user.id) if current_user
    @books = @books.search_for(params[:search]) if params[:search].present?
    @books = @books.paginate(:page => params[:page], :per_page => 6)
    render :layout => "application", :template => "books/public_search" if current_user.blank?
  end

  def requested
    @books = current_school.books
    @my_requested_books = current_user.books.where(:requested => true).order("created_at DESC")
    @requested_books = @books.where(:requested => true).order("created_at DESC")
    respond_to do |format|
      format.html
    end
  end
end
