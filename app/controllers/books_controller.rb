class BooksController < ApplicationController
  before_filter :require_login, :except => [:show, :available, :campus_bookshelf]

  layout "dashboard"

  def index
    @books = current_user.books.where(:requested => false).paginate(:page => params[:page], :per_page => 6)
  end

  def new
    @book = current_user.books.new
    if params[:google_book_id]
      @book.set_google(params[:google_book_id])
    end
    if params[:requested]
      @requested_book = true
    end
    if params[:book_id]
      @from_database = true
      @book.set_db(params[:book_id])
    end
  end

  def create
    unless params[:search] == "Search"
      @book = current_user.books.new(params[:book])
      if params[:remote_url].present?
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

  def show_search
    if params[:google_book_id]
      @book = GoogleBooks.search(params[:google_book_id]).first
    elsif params[:db_book_id]
      @book = Book.find(params[:db_book_id])
    end
    respond_to do |format|
      format.html
    end
  end

  def available
    @books = current_school.books.available_now.date_not_expired
    @books = @books.not_my_book(current_user.id) if current_user
    @books = @books.search_for(params[:search]) if params[:search].present?
    @books = @books.paginate(:page => params[:page], :per_page => 6)
    @recent_books = current_school.books.available_now.date_not_expired.order("created_at desc").limit(10)
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

  def search
    @books = Book.search_for(params[:value]).paginate(:page => params[:page], :per_page => 8)
    if params[:next]
      session[:book_page] = session[:book_page] + 1
    else
      session[:book_page] = 1
    end
    if params[:value]
      @google_books  = GoogleBooks.search(params[:value], {:count => 15, :page => session[:book_page] })
      @google_books = prepare(@google_books)
    elsif params[:book_isbn_for_price]
      res = Amazon::Ecs.item_search(params[:book_isbn_for_price], {:response_group => "Medium", :search_index => 'Books'})
      unless res.has_error?
        book = res.items.first
        if book.get_element('ItemAttributes').get_element('ListPrice').present?
          book_price = book.get_element('ItemAttributes').get_element('ListPrice').get('Amount').to_f
        elsif book.get_element('OfferSummary').get_element('LowestNewPrice').present?
          book_price = book.get_element('OfferSummary').get_element('LowestNewPrice').get('Amount').to_f
        elsif book.get_element('OfferSummary').get_element('LowestUsedPrice').present?
          book_price = book.get_element('OfferSummary').get_element('LowestUsedPrice').get('Amount').to_f
        end
        @book_price_from_amazon = book_price/100
      end
    end
    respond_to do |format|
      if params[:next] or params[:page]
        format.js
      elsif params[:book_isbn_for_price]
        format.js { render 'book_price.js.erb'}
      else
        format.json { render :json => @google_books }
      end
      format.html
    end
  end

  def prepare(google_books)
    @google_books  = google_books.map {|book| { :image_url => book.image_link(:zoom => 1),
        :publisher => book.publisher,
        :title => book.title,
        :author => book.authors,
        :isbn => book.isbn,
        :id => book.id
      }}
    @google_books = @google_books.map {|item| Hashit.new(item)}
    return @google_books
  end

  def campus_bookshelf
    @books = current_school.books.paginate(:page => params[:page], :per_page => 6)
    render :action => 'available' if current_user.present?
    render :layout => "application", :template => "books/public_search" if current_user.blank?
  end
end