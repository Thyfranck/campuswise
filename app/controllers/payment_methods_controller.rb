class PaymentMethodsController < ApplicationController

  before_filter :require_login

  layout "dashboard"

  def new
    respond_to do |format|
      if current_user.payment_method.present?
        @payment_method = current_user.payment_method
        format.html {render :action => 'show'}
      else
        @payment_method = PaymentMethod.new
        format.html
      end
    end
  end

  def create
    if params[:payment_method]
      @payment_method = PaymentMethod.new(params[:payment_method])
      @payment_method.user_id = current_user.id
      respond_to do |format|
        if @payment_method.save
          format.html {redirect_to dashboard_path, :notice => "Request completed" }
        else
          format.html {render :action => 'new'}
        end
      end
    end
  end

  def show
    @payment_method = current_user.payment_method
  end

  def edit
    @payment_method = current_user.payment_method
    respond_to do |format|
      format.html
    end
  end

  def destroy
    @payment_method = current_user.payment_method
    @payment_method.destroy
    redirect_to dashboard_path, :notice => "Request Completed"
  end

end