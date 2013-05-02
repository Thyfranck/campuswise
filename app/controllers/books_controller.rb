class BooksController < ApplicationController
  before_filter :require_login

  layout "dashboard"

  def index
    @books = current_user.books
  end

  def new
    @book = current_user.books.new
  end

  def create
    @book = current_user.books.new(params[:book])
    respond_to do |format|
      if @book.save
        format.html {redirect_to books_path}
        flash[:notice] = "Request Completed"
      else
        format.html {render :action => 'new'}
      end
    end
  end

  def show
    @book = Book.find(params[:id])
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book= Book.find(params[:id])
    respond_to do |format|
      if @book.update_attributes(params[:book])
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
    @books = GoogleBooks.search(params[:value], {:count => 10})
    @search_result = @books.map {|book| { :image_link => book.image_link,
        :publisher => book.publisher,
        :title => book.title,
        :authors => book.authors,
        :isbn => book.isbn
      }}
    respond_to do |format|
      format.json { render :json => @search_result }
    end
  end
end
