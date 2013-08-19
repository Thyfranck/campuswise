class UsersController < ApplicationController

  before_filter :require_login, :except => [:new, :create, :activate, :new_password, :create_password, :new_phone, :create_phone, :sms_verification, :verify_code, :send_verification_sms ]

  load_and_authorize_resource :only => [:edit, :update, :show, :destroy]

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html {render layout: "dashboard"}
      format.json { render json: @user }
    end
  end

  def new   
    if current_user
      redirect_to user_path(current_user)
    else
      if current_school.present?
        @user = User.new
        respond_to do |format|
          format.html
          format.json { render json: @user }
        end
      else
        redirect_to root_path
      end
    end
    
  end

  def edit
    @school = current_user.school
    @user = User.find(params[:id])
    @user.email = @user.email.gsub(/\@\S*/, "")
    render layout: "dashboard"
  end

  def create  
    @school = School.find(params[:user][:school_id])
    @user = User.new(params[:user])
    @user.make_email_format
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to school_home_path, notice: 'Please check your email to activate your account.' }
      else
        @user.email = @user.email.gsub(/\@\S*/, "")
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    @school = @user.school
    params[:user][:email] = "#{params[:user][:email]}"+"@"+"#{@user.school.email_postfix}" if params[:user][:email].present?
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { 
          if params[:user][:current_password].present?
            render action: "change_password", layout: "dashboard"
          else
            render action: 'new'
          end
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @user.activate!
      @school = @user.school
      session[:user_tmp_id] = @user.id
      redirect_to new_password_user_path(@user), :notice => "Successfully activated your account. Please create password for your account."
    else
      not_authenticated
    end
  end

  def new_password
    @user = User.find(session[:user_tmp_id])
  end

  def create_password
    @user = User.find(session[:user_tmp_id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to new_phone_user_path(@user), :notice => "Please give your mobile phone number." }
      else
        format.html { render action: "new_password" }
      end
    end
  end

  def new_phone
    @user = User.find(session[:user_tmp_id])
  end

  def create_phone
    @school = current_school
    @user = User.find(session[:user_tmp_id])
    
    if @user.update_attributes(params[:user]) and @user.phone.present?
      begin
        @user.set_phone_verification
        @user.save
        @user.send_sms_verification
        redirect_to sms_verification_user_path(@user), :notice => "Verification sms sent! Please check your mobile phone."
      rescue Twilio::REST::RequestError
        @user.errors.add(:phone, "number you entered #{@user.phone} is not a valid phone number")
        render action: "new_phone"
      end
    else
      render action: "new_phone"
    end
  end

  def change_password
    @user = User.find(params[:id])
    respond_to do |format|
      format.html { render layout: "dashboard" }
    end
  end

  def send_verification_sms
    @user = User.find(session[:user_tmp_id])
    @user.send_sms_verification
    redirect_to sms_verification_user_path(@user), :notice => "Verification sms sent! Please check your mobile phone."
  end

  def sms_verification
    @user = User.find(session[:user_tmp_id])
    respond_to do |format|
      if @user.phone_verified == "verified"
        format.html { redirect_to dashboard_path, :notice => "Logged in"}
      else
        format.html
      end
    end
  end

  def verify_code
    @user = User.find(session[:user_tmp_id])
    @verified_user = User.find_by_phone_verification(params[:code])
    if @verified_user == @user
      @user.verify_phone
      auto_login(@user)
      redirect_to dashboard_path, :notice => "Your phone is now verified!"
    else
      redirect_to sms_verification_user_path(@user), :alert => "Invalid Code"
    end
  end

  def dashboard
    @notifications = current_user.dashboard_notifications.order("created_at DESC").paginate(:page => params[:page], :per_page => 10)
    respond_to do |format|
      format.html {render :layout => "dashboard"}
    end
  end

  def remove_notification
    @notification = DashboardNotification.find(params[:id])
    respond_to do |format|
      if @notification.update_attribute(:seen, true)
        format.html { redirect_to dashboard_path}
      else
        format.html { redirect_to dashboard_path, :alert => 'Error Occured'}
      end
    end
  end

  def borrow_requests
    @borrowed_books = current_user.accepted_exchanges.paginate(:page => params[:page], :per_page => 6)
    @pending_for_owner = current_user.pending_exchanges.paginate(:page => params[:page], :per_page => 6)
    @pending_for_me = current_user.pending_reverse_exchanges.paginate(:page => params[:page], :per_page => 6)
    @lended = current_user.accepted_reverse_exchanges.paginate(:page => params[:page], :per_page => 6)
    @not_returned = current_user.not_returned_exchanges.paginate(:page => params[:page], :per_page => 6)
    @completed_transactions = current_user.completed_transactions.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html {render :layout => "dashboard"}
    end
  end

  def payment
    respond_to do |format|
      format.html {render layout: "dashboard"}
    end
  end

  def notification_count
    @notifications = current_user.dashboard_notifications.count
    respond_to do |format|
      format.json { render :json => @notifications }
    end
  end

  def wallet
    @user = User.find(params[:id])
    @transactions = @user.transactions.order("id DESC").paginate(:page => params[:page], :per_page => 20)
#    @credit_transactions = @user.transactions.where(:transactable_type => Exchange).paginate(:page => params[:page], :per_page => 20)
#    @debit_transactions = @user.transactions.where(:transactable_type => WithdrawRequest).paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html {render layout: "dashboard"}
    end
  end

#  def history
#    @completed_transactions = current_user.completed_transactions.paginate(:page => params[:page], :per_page => 20)
#    respond_to do |format|
#      format.html {render layout: "dashboard"}
#    end
#  end
end