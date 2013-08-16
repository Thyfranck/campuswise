class PaymentMethodsController < ApplicationController

  before_filter :require_login

  layout "dashboard"

  def index
    @payment_methods = current_user.payment_methods
  end

  def new
    @methods = Constant::PAYMENT_METHOD_TYPE
    respond_to do |format|
      if current_user.payment_methods.any?
        current_user.payment_methods.each do |d|
          @methods.delete(d.payment_method_type)
        end
        if @methods.length > 0
          @payment_method = current_user.payment_methods.new
          format.html
        else
          format.html {redirect_to current_user, :notice => "No more payment methods to add"}
        end
      else
        @payment_method = PaymentMethod.new
        format.html
      end
    end
  end

  def create
    @methods = Constant::PAYMENT_METHOD_TYPE
    if current_user.payment_methods.any?
      current_user.payment_methods.each do |d|
        @methods.delete(d.payment_method_type)
      end
    end
    if params[:payment_method]
      @payment_method = PaymentMethod.new(params[:payment_method])
      @payment_method.user_id = current_user.id
      respond_to do |format|
        if @payment_method.save
          if session[:withdraw_request] == "yes"
            format.html { redirect_to new_withdraw_request_path }
          else
            format.html {redirect_to payment_methods_path, :notice => "Request completed" }
          end
          
        else
          format.html {render :action => 'new'}
        end
      end
    end
  end

  def show
    @payment_method = PaymentMethod.find(params[:id])
  end

  def edit
    @payment_method = PaymentMethod.find(params[:id])
    @methods = ["#{@payment_method.payment_method_type}"]
    respond_to do |format|
      format.html
    end
  end

  def update
    @payment_method = PaymentMethod.find(params[:id])
    @payment_method.update_attributes(params[:payment_method])
    respond_to do |format|
      format.html {redirect_to payment_method_path(@payment_method), :notice => "Request Completed"}
    end
  end

  def destroy
    @payment_method = PaymentMethod.find(params[:id])
    @payment_method.destroy
    redirect_to payment_methods_path, :notice => "Request Completed"
  end

end