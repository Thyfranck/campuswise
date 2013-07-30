class BooksController < ApplicationController
  before_filter :require_login, :except => [:show, :available, :campus_bookshelf, :borrow, :buy]
  load_and_authorize_resource :except => [:show, :available, :campus_bookshelf, :borrow, :buy ]
  before_filter :require_buy_prerequisites, :only => [:buy]
  before_filter :require_borrow_prerequisites, :only => [:borrow]


  layout "dashboard"

  def index
    @books = current_user.books.paginate(:page => params[:page], :per_page => 6)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @book = current_user.books.new
    if params[:google_book_id]
      @book.set_google(params[:google_book_id])
    end
    unless params[:google_book_id] or params[:requested]
      @new_book_page = true
    end
    if params[:requested]
      session[:requested] = 'yes'
    else
      session[:requested] = nil
    end
    if session[:requested] == 'yes'
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
      if session[:requested] == 'yes'
        session[:requested] = nil
      end
      respond_to do |format|
        if @book.save
          format.html {redirect_to book_path(@book)}
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
    if current_user
    else
      if @book.unavailable?
        redirect_to root_path, :notice => "Unautorized!"
      else
        render :layout => "application", :template => "books/public_view" if current_user.blank?
      end
    end   
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
        format.html {redirect_to book_path(@book)}
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
        flash[:alert] = "The book can not be deleted now."
      end
    end
  end

  def show_search
    if params[:google_book_id]
      @book = GoogleBooks.search(params[:google_book_id], {}, "4.2.2.1").first
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

    @needed_books = current_school.books.needed
    @needed_books = @needed_books.search_for(params[:search]) if params[:search].present?
    @needed_books = @needed_books.paginate(:page => params[:page], :per_page => 6)

    @recent_books = current_school.books.available_now.date_not_expired.order("created_at desc").limit(10)
    @recent_needed_books = current_school.books.needed.order("created_at desc").limit(10)
    
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
      @google_books  = GoogleBooks.search(params[:value], {:count => 15, :page => session[:book_page] }, "4.2.2.1")
      g = @google_books.to_a
      @google_books = prepare(@google_books) if g.length > 0
      #    elsif params[:book_isbn_for_price]
      #      res = Amazon::Ecs.item_search(params[:book_isbn_for_price], {:response_group => "Medium", :search_index => 'Books'})
      #      unless res.has_error?
      #        book = res.items.first
      #        if book.get_element('ItemAttributes').get_element('ListPrice').present?
      #          book_price = book.get_element('ItemAttributes').get_element('ListPrice').get('Amount').to_f
      #        elsif book.get_element('OfferSummary').get_element('LowestNewPrice').present?
      #          book_price = book.get_element('OfferSummary').get_element('LowestNewPrice').get('Amount').to_f
      #        elsif book.get_element('OfferSummary').get_element('LowestUsedPrice').present?
      #          book_price = book.get_element('OfferSummary').get_element('LowestUsedPrice').get('Amount').to_f
      #        end
      #        @book_price_from_amazon = book_price/100
      #      end
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
    @books = current_school.books.available_now.date_not_expired.paginate(:page => params[:page], :per_page => 6)
    @recent_books = current_school.books.available_now.date_not_expired.order("created_at desc").limit(10)
    @needed_books = current_school.books.needed.paginate(:page => params[:page], :per_page => 6)
    respond_to do |format|
      format.html do
        render :action => 'available' if current_user.present?
        render :layout => "application", :template => "books/public_search" if current_user.blank?
      end
      format.js {render :action => 'campus_bookshelf'}
    end
  end

  def all
    @books = current_school.books.available_now.date_not_expired
    @books = @books.not_my_book(current_user.id) if current_user
    @books = @books.search_for(params[:search]) if params[:search].present?
    @books = @books.paginate(:page => params[:page], :per_page => 6)

    @recent_books = current_school.books.available_now.date_not_expired.order("created_at desc").limit(10)
  end

  def buy
    @book = Book.find(params[:id])

    if params[:exchange].present?
      @exchange = current_user.exchanges.new(params[:exchange])
      @exchange.book_id = @book.id

      if @exchange.save
        redirect_to user_path(current_user), :notice => "Request sent to owner for approval."
      end
    else
      @exchange = Exchange.new
    end
  end

  def borrow
    @book = Book.find(params[:id]) or Book.find(params[:exchange][:book_id])
    if params[:exchange].present?
      @exchange = current_user.exchanges.new(params[:exchange])
      if @exchange.valid?
        if current_user.billing_setting.present?
          if @exchange.save
            session[:exchange] = nil
            redirect_to user_path(current_user), :notice => "Request sent to owner for approval."
          end
        else
          session[:exchange] = nil
          session[:exchange] = params[:exchange]
          redirect_to new_billing_setting_path, :notice => "Please add your billing information! Your card will not be charged before your confirmation."
        end
      else
      end
    else
      @exchange = Exchange.new
    end
  end


  private
  
  def require_buy_prerequisites
    @book = Book.find(params[:id])
    if current_user.blank?
      session[:referer] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      redirect_to login_path, :notice => "You must login to book or buy a book!"
    elsif current_user.not_eligiable_to_borrow_or_buy(@book)
      redirect_to current_user, :notice => "You are not allowed to borrow this book."
    elsif current_user.billing_setting.blank?
      session[:referer] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      redirect_to new_billing_setting_path, :notice => "Please add your billing information! Your card will not be charged before your confirmation."
    end
  end

  def require_borrow_prerequisites
    @book = Book.find(params[:id])
    if current_user.blank?
      session[:referer] = "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
      redirect_to login_path, :notice => "You must login to book or buy a book!"
    elsif current_user.not_eligiable_to_borrow_or_buy(@book)
      redirect_to current_user, :notice => "You are not allowed to borrow this book."
    end
  end
end