class WithdrawRequestsController < ApplicationController
  before_filter :require_login
  
  layout "dashboard"

  def index
    @withdraw_requests = current_user.withdraw_requests.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
  end

  def new
    if current_user.payment_methods.any?
      if current_user.current_balance.to_f > 0.0
        session[:withdraw_request] = nil if session[:withdraw_request]
        @methods = current_user.payment_methods.map(&:payment_method_type)
        @withdraw_request = WithdrawRequest.new
      else
        redirect_to user_path(current_user), :alert => 'You dont have enough credit.'
      end
    else
      session[:withdraw_request] = "yes"
      redirect_to new_payment_method_path
      flash[:notice] = "Please specify a payment method first."
    end
  end

  def create
    @withdraw_request = current_user.withdraw_requests.new(params[:withdraw_request])
    respond_to do |format|
      if @withdraw_request.save
        format.html {redirect_to withdraw_requests_path, :notice => "Request Completed"}
      else
        @methods = current_user.payment_methods.map(&:payment_method_type)
        format.html {render :action => 'new'}
      end
    end
  end
end