class BillingSettingsController < ApplicationController

  before_filter :require_login

  layout "dashboard"
  
  def new
    respond_to do |format|
      if current_user.billing_setting.present?
        @billing_setting = current_user.billing_setting
        format.html {render :action => 'show'}
      else
        @billing_setting = BillingSetting.new
        format.html
      end
    end
  end

  def create
    if params[:stripe_token].present?
      if current_user.billing_setting.present?
        current_user.billing_setting.stripe_token = params[:stripe_token]
        current_user.billing_setting.save
      else
        BillingSetting.create(:user_id => current_user.id, :stripe_token => params[:stripe_token])
      end
      respond_to do |format|
        if session[:wanted_to_exchange_book]
          format.html { redirect_to new_exchange_path(:id => session[:wanted_to_exchange_book])}
        else
          format.html { redirect_to current_user, :notice => "Request completed"}
        end
      end
    end
  end

  def show
    @billing_setting = current_user.billing_setting
  end

  def edit
    respond_to do |format|
      format.html
    end
  end
end