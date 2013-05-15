class ExchangesController < ApplicationController
  before_filter :require_login, :except => [:process_sms]
  before_filter :verify_authenticity_token, :except => [:process_sms]

  layout "dashboard"

  def new
    @book = Book.find(params[:id])
    if current_user.billing_setting.present?
    respond_to do |format|
      if current_user.eligiable_to_borrow(@book)
        @exchange = Exchange.new
        format.html
      else
        format.html { redirect_to current_user, :notice => "You are not allowed to borrow this book."}
      end
    end
    else
      session[:wanted_to_exchange_book] = @book.id
      redirect_to new_billing_setting_path, :notice => "Please setup your payment settings first"
    end
  end

  def create
    @book = Book.find(params[:exchange][:book_id])
    @exchange = current_user.exchanges.new(params[:exchange])
    respond_to do |format|
      if @exchange.save
        format.html {redirect_to user_path(current_user), :notice => "Request sent to owner for approval."}
      else
        format.html {render :action => 'new'}
      end
    end
  end

  def update
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
       @exchange.charge
       format.html { redirect_to dashboard_path, :notice => "Request is in process."}
    end
  end

  def destroy
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      if @exchange.destroy
        format.html {redirect_to request.referrer, :alert => "You Rejected the request"}
      end
    end
  end

  def process_sms
    @from = params[:From]
    @user = User.find_by_phone(@from)
    if @user
      @body = params[:Body]
      @body = @body.downcase
      if @body.include?("yes")
        @id = @body.gsub("yes", "")
        @exchange = Exchange.find(@id)
        if @exchange and @exchange.book.user.id == @user.id
          @exchange.charge
          render 'exchanges/sms/before_charge_yes.xml.erb', :content_type => 'text/xml'
        else
          render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
        end
      elsif @body.include?("no")
        @id = @body.gsub("no", "")
        @exchange = Exchange.find(@id)
        if @exchange and @exchange.book.user.id == @user.id
          @exchange.destroy
          render 'exchanges/sms/no.xml.erb', :content_type => 'text/xml'
        else
          render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
        end
      else
        render 'exchanges/sms/invalid.xml.erb', :content_type => 'text/xml'
      end
    else
      render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
    end   
  end

  def search
    respond_to do |format|
      format.html
    end
  end

end