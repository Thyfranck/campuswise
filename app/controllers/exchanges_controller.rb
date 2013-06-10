class ExchangesController < ApplicationController
  before_filter :require_login, :except => [:process_sms]
  before_filter :verify_authenticity_token, :except => [:process_sms]

  layout "dashboard"

  def new
    @book = Book.find(params[:id])
    if session[:wanted_to_exchange_book]
      session[:wanted_to_exchange_book] = nil
    end
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
      if @exchange.counter_offer.present?
        @status = params[:agree]
        if @status == "agree"
          @exchange.update_attributes(:amount => @exchange.counter_offer, :counter_offer_last_made_by => current_user.id)
          start(@exchange, format)
        elsif @status == "disagree"
          if @exchange.book.user == current_user
            @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, current_user.id)
            @dashboard.destroy if @dashboard.present?
            @exchange.update_attributes(:counter_offer => @exchange.amount, :counter_offer_last_made_by => current_user.id)
          elsif @exchange.user == current_user
            @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, current_user.id)
            @dashboard.destroy if @dashboard.present?
            @exchange.destroy
          end
          format.html { redirect_to dashboard_path, :notice => "Request is in process."}
        elsif @status == "negotiate"
          @amount = params[:negotiate]
          if @exchange.book.user == current_user
            if @exchange.update_attributes(:amount => @amount, :counter_offer_last_made_by => current_user.id, :counter_offer_count => @exchange.counter_offer_count + 1)
              format.html { redirect_to dashboard_path, :notice => "Request is in process."}
            else
              format.html { redirect_to dashboard_path, :alert => "Invalid negotiation."}
            end
          elsif @exchange.user == current_user
            if @exchange.update_attributes(:counter_offer => @amount, :counter_offer_last_made_by => current_user.id)
              format.html { redirect_to dashboard_path, :notice => "Request is in process."}
            else
              format.html { redirect_to dashboard_path, :alert => "Invalid negotiation."}
            end
          end
        end
      else
        start(@exchange)
      end
    end
  end

  def start(exchange, format)
    @exchange = Exchange.find(exchange)
    if @exchange.book.available == true
      unless @exchange.other_pending_payment_present?
        if @exchange.delay.charge
          @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, current_user.id)
          @dashboard.destroy if @dashboard.present?
          format.html {redirect_to dashboard_path, :notice => "Request is in process."}
        elsif @exchange.errors.any?
          @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, current_user.id)
          @dashboard.destroy if @dashboard.present?
          format.html { redirect_to dashboard_path, :alert => @exchange.errors.full_messages.to_sentence.gsub("Your","The Users")}
        end
      else
        format.html { redirect_to dashboard_path, :notice => "Already a request for this book is under process."}
      end
    end
  end

  def destroy
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, current_user.id).destroy
      @exchange.destroy
      format.html {redirect_to request.referrer, :notice => "You Rejected the request"}
    end
  end

  def returned
    @exchange = Exchange.find(params[:id])
    if params[:returned] == "true"
      @exchange.update_attribute(:status, Exchange::STATUS[:returned])
    elsif params[:returned] == "false"
      @exchange.update_attribute(:status, Exchange::STATUS[:not_returned])
    end
    redirect_to request.referrer
  end

  def process_sms
    @from = params[:From]
    @user = User.find_by_phone(@from)
    if @user
      @body = params[:Body]
      @body = @body.downcase
      if @body.match(/accept\s*/).present?
        @id = @body.gsub /\D/, ""   
        if @exchange = Exchange.find(@id) and @exchange.book.user.id == @user.id and @exchange.book.available == true
          @old_dashboard_notification = DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, @user.id)
          @old_dashboard_notification.destroy
          @exchange.delay.charge
          render 'exchanges/sms/processing.xml.erb', :content_type => 'text/xml'
        else
          render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
        end
      elsif @body.match(/reject\s*/).present?
        @id = @body.gsub /\D/, "" 
        if @exchange = Exchange.find(@id) and @exchange.book.user.id == @user.id and @exchange.book.available == true
          @old_dashboard_notification = DashboardNotification.find_by_dashboardable_id_and_user_id(@exchange.id, @user.id)
          @old_dashboard_notification.destroy
          @exchange.destroy
          render 'exchanges/sms/no.xml.erb', :content_type => 'text/xml'
        else
          render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
        end
      elsif @body.match(/yes\s*/).present?
        @id = @body.gsub /\D/, ""
        if @exchange = Exchange.find(@id) and @exchange.book.user.id == @user.id
          if @exchange.status == Exchange::STATUS[:accepted]
            @exchange.update_attribute(:status, Exchange::STATUS[:returned])
            render 'exchanges/sms/processing.xml.erb', :content_type => 'text/xml'
          end
        else
          render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
        end
      elsif @body.match(/no\s*/).present?
        @id = @body.gsub /\D/, ""
        if @exchange = Exchange.find(@id) and @exchange.book.user.id == @user.id
          if @exchange.status == Exchange::STATUS[:accepted]
            @exchange.update_attribute(:status, Exchange::STATUS[:not_returned])
            render 'exchanges/sms/processing.xml.erb', :content_type => 'text/xml'
          end
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

  def before
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

end