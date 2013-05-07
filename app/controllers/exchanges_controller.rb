class ExchangesController < ApplicationController
  before_filter :require_login

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
        @exchange.destroy_other_pending_requests
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

end