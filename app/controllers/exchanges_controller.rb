class ExchangesController < ApplicationController
  before_filter :require_login, :except => [:process_sms]
  before_filter :verify_authenticity_token, :except => [:process_sms]

  layout "dashboard"

  def new
    respond_to do |format|
      format.html
    end
  end

  def create
    @exchange = current_user.exchanges.new(:book_id => params[:id])
    respond_to do |format|
      if @exchange.save
        format.html {redirect_to user_path(current_user), :notice => "Request sent to owner for approval."}
      else
        format.html {redirect_to user_path(current_user), :alert => "Error Occured."}
      end
    end
  end

  def update
    @exchange = Exchange.find(params[:id])
    respond_to do |format|
      if @exchange.update_attributes(:accepted => true)
        format.html {redirect_to request.referrer, :notice => "You Accepted the request"}
      else
        format.html {redirect_to request.referrer, :alert => "Error Occured"}
      end
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
          @exchange.update_attribute(:accepted, true)
          render 'exchanges/sms/yes.xml.erb', :content_type => 'text/xml'
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

end