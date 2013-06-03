class WithdrawRequestsController < ApplicationController
  before_filter :require_login
  
  layout "dashboard"

  def index
    @withdraw_requests = current_user.withdraw_requests.order("created_at DESC")
  end

  def new
    @withdraw_request = WithdrawRequest.new
  end

  def create
    @withdraw_request = current_user.withdraw_requests.new(params[:withdraw_request])
    respond_to do |format|
      if @withdraw_request.save
        format.html {redirect_to withdraw_requests_path, :notice => "Request Completed"}
      else
        format.html {render :action => 'new'}
      end
    end
  end
end