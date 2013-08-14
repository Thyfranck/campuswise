class ExchangesController < ApplicationController
  before_filter :require_login, :except => [:process_sms]
  before_filter :verify_authenticity_token, :except => [:process_sms]

  layout "dashboard"

  #  def new
  #    @book = Book.find(params[:id])
  #    if params[:buy] == 'yes'
  #      @buy = true
  #    else
  #      @buy = false
  #    end if params[:buy].present?
  #
  #    if session[:wanted_to_exchange_book]
  #      session[:wanted_to_exchange_book] = nil
  #    end
  #    #    if current_user.billing_setting.present?
  #    respond_to do |format|
  #      if current_user.eligiable_to_borrow(@book)
  #        @exchange = Exchange.new
  #        format.html
  #      else
  #        format.html { redirect_to current_user, :notice => "You are not allowed to borrow this book."}
  #      end
  #    end
  #    else
  #      session[:wanted_to_exchange_book] = @book.id
  #      redirect_to new_billing_setting_path, :notice => "Please setup your payment settings first"
  #    end
  #  end

  #  def create
  #    @book = Book.find(params[:exchange][:book_id])
  #    respond_to do |format|
  #      if current_user.billing_setting.blank?
  #        session[:exchange] = params[:exchange]
  #        redirect_to new_billing_setting_path, :notice => "Please setup your payment settings first"
  #      else
  #        if session[:exchange]
  #          @exchange = current_user.exchanges.new(session[:exchange])
  #        else
  #          @exchange = current_user.exchanges.new(params[:exchange])
  #        end
  #        if @exchange.save
  #          session[:exchange] = nil if session[:exchange].present?
  #          format.html {redirect_to user_path(current_user), :notice => "Request sent to owner for approval."}
  #        else
  #          format.html {render :action => 'new'}
  #        end
  #      end
  #    end
  #  end

  def update
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      if @exchange.counter_offer.present?
        @status = params[:agree]
        if @status == "agree"
          if @exchange.book.user == current_user
            start(@exchange, format) if @exchange.update_attributes(:amount => @exchange.counter_offer.to_f, :counter_offer_last_made_by => current_user.id)
          end
        
          if @exchange.user == current_user
            start(@exchange, format) if @exchange.update_attributes(:counter_offer => @exchange.amount.to_f)
          end
        elsif @status == "disagree"
          if @exchange.book.user == current_user
            counter_offer = @exchange.counter_offer.to_f
            @exchange.counter_offer = @exchange.amount.to_f
            @exchange.counter_offer_last_made_by = current_user.id
            if @exchange.save(:validate => false)
              Notify.delay.borrower_about_owner_doesnt_want_to_negotiate(@exchange, counter_offer )
              @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
              @dashboards.each do |dashboard|
                dashboard.update_attribute(:seen, true)
              end if @dashboards.any?
              format.html { redirect_to dashboard_path, :notice => "Request is in process."}
            else
              format.html { redirect_to dashboard_path, :alert => "Error occured"}
            end
          elsif @exchange.user == current_user
            Notify.owner_about_negotiation_failed(@exchange)
            if @exchange.destroy
              @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
              @dashboards.each do |dashboard|
                dashboard.update_attribute(:seen, true)
              end if @dashboards.any?
              format.html { redirect_to dashboard_path, :notice => "Request is in process."}
            else
              format.html { redirect_to dashboard_path, :alert => "Error Occured."}
            end
          end
        elsif @status == "negotiate"
          @amount = params[:negotiate]
          if @exchange.book.user == current_user
            if @exchange.amount.to_f == @amount.to_f
              format.html { redirect_to dashboard_path, :alert => "Please provide a price that is lower than the previous one."}
            else
              if @exchange.update_attributes(:amount => @amount, :counter_offer_last_made_by => current_user.id, :counter_offer_count => @exchange.counter_offer_count + 1)
                Notify.delay.borrower_about_owner_want_to_negotiate(@exchange)
                @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
                @dashboards.each do |dashboard|
                  dashboard.update_attribute(:seen, true)
                end if @dashboards.any?
                format.html { redirect_to dashboard_path, :notice => "Request is in process."}
              else
                format.html { redirect_to dashboard_path, :alert => "Invalid negotiation."}
              end
            end
          elsif @exchange.user == current_user
            if @exchange.update_attributes(:counter_offer => @amount, :counter_offer_last_made_by => current_user.id)
              Notify.delay.owner_about_borrower_want_to_negotiate(@exchange)
              @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
              @dashboards.each do |dashboard|
                dashboard.update_attribute(:seen, true)
              end if @dashboards.any?
              format.html { redirect_to dashboard_path, :notice => "Request is in process."}
            else
              format.html { redirect_to dashboard_path, :alert => "Invalid negotiation."}
            end
          end
        end
      else
        if @exchange.book.user == current_user
          start(@exchange, format)
        else
          format.html {redirect_to dashboard_path, :alert => "Unauthorized"}
        end
      end
    end
  end

  def start(exchange, format)
    @exchange = Exchange.find(exchange)
    if @exchange.book.available == true
      unless @exchange.other_pending_payment_present?
        if @exchange.delay.charge
          @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
          @dashboards.each do |dashboard|
            dashboard.update_attribute(:seen, true)
          end if @dashboards.any?
          format.html {redirect_to dashboard_path, :notice => "Request is in process."}
        elsif @exchange.errors.any?
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
      @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
      @dashboards.each do |dashboard|
        dashboard.update_attribute(:seen, true)
      end if @dashboards.any?
      if @exchange.user == current_user and @exchange.counter_offer.present?
        Notify.owner_about_negotiation_failed(@exchange)
      elsif @exchange.book.user == current_user
        Notify.borrower_about_rejected_by_owner(@exchange)
      end
      @exchange.destroy
      format.html {redirect_to request.referrer, :notice => "You Rejected the request"}
    end
  end

  def status
    @exchange = Exchange.find(params[:id])
    if params[:status] == "returned" and @exchange.book.user == current_user
      Notify.delay.admin_for_book_returned(@exchange) if @exchange.update_attributes(:status => Exchange::STATUS[:returned],:owner_id => @exchange.book.user.id, :book_title => @exchange.book.title)
    elsif params[:status] == "not_returned" and @exchange.book.user == current_user
      Notify.delay.admin_for_book_not_returned(@exchange) if @exchange.update_attribute(:status, Exchange::STATUS[:not_returned])
    elsif params[:status] == "dropped_off" and @exchange.book.user == current_user
      Notify.delay.book_dropped_off(@exchange) if @exchange.update_attributes(:dropped_off => Exchange::STATUS[:dropped_off], :dropped_off_at => Time.now)
    elsif params[:status] == "received" and @exchange.user == current_user
      if @exchange.package == "buy"
        Notify.delay.book_received(@exchange) if @exchange.update_attributes(:received => Exchange::STATUS[:received], :received_at => Time.now, :status =>  Exchange::STATUS[:received])
      else
        Notify.delay.book_received(@exchange) if @exchange.update_attributes(:received => Exchange::STATUS[:received], :received_at => Time.now)
      end
      @exchange.update_attributes(:dropped_off => Exchange::STATUS[:dropped_off], :dropped_off_at => Time.now) if @exchange.dropped_off.blank?
    else
      @msg = "Unauthorized"
    end
    @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, current_user.id, false)
    @dashboards.each do |dashboard|
      dashboard.update_attribute(:seen, true)
    end if @dashboards.any?
    redirect_to request.referrer, :notice => @msg or "Request Completed"
  end

  def process_sms
    @from = params[:From]
    @user = User.find_by_phone(@from)
    @body = params[:Body]
    @id = @body.gsub /\D/, ""
    @exchange = Exchange.find(@id)
    unless @exchange.counter_offer.present?
      if @user
        @body = params[:Body]
        @body = @body.downcase
        if @body.match(/accept\s*/).present?
          @id = @body.gsub /\D/, ""
          if @exchange = Exchange.find(@id) and @exchange.book.user.id == @user.id and @exchange.book.available == true
            @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, @user.id, false)
            @dashboards.each do |dashboard|
              dashboard.update_attribute(:seen, true)
            end if @dashboards.any?
            @exchange.delay.charge
            render 'exchanges/sms/processing.xml.erb', :content_type => 'text/xml'
          else
            render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
          end
        elsif @body.match(/reject\s*/).present?
          @id = @body.gsub /\D/, ""
          if @exchange = Exchange.find(@id) and @exchange.book.user.id == @user.id and @exchange.book.available == true
            @dashboards = DashboardNotification.where("dashboardable_id = ? AND user_id = ? AND seen = ?", @exchange.id, @user.id, false)
            @dashboards.each do |dashboard|
              dashboard.update_attribute(:seen, true)
            end if @dashboards.any?
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
    else
      render 'exchanges/sms/unauthorized.xml.erb', :content_type => 'text/xml'
    end
  end

  def search
    @book = current_user.books.new
    @requested_book = true and session[:requested] = 'yes'
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