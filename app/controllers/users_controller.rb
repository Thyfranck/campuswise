class UsersController < ApplicationController

  before_filter :require_login, :except => [:new, :create, :activate, :sms_verification, :verify_code ]


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
    @email_postfix = @school.present? ? "#{@school.email_postfix }" : nil
    unless params[:user][:email].blank?
      params[:user][:email] =  "#{params[:user][:email]}"+"@"+"#{@email_postfix}"
    end
    @user = User.new(params[:user])
    @user.set_phone_verification
    respond_to do |format|
      if @user.save
        format.html { redirect_to login_path(:school => @school), notice: 'Please Check your email for verification code.' }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])
    params[:user][:email] = "#{params[:user][:email]}"+"@"+"#{@user.school.email_postfix}"
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to edit_user_path(@user), :alert => "Error Occured" }
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
      redirect_to(login_path(:school => @school), :notice => 'User was successfully activated. Use your email and password to login.')
    else
      not_authenticated
    end
  end

  def sms_verification
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def verify_code
    @code = params[:code]
    @logged_user = User.find(params[:logged_user])
    @user = User.find_by_phone_verification(@code)
    if @user == @logged_user
      @user.verify_phone
      auto_login(@user)
      redirect_to dashboard_path, :notice => "Your phone is now verified"
    else
      redirect_to sms_verification_path, :alert => "Invalid Code"
    end
  end

  def dashboard
    @notifications = current_user.dashboard_notifications.order("created_at DESC")
    respond_to do |format|
      format.html {render :layout => "dashboard"}
    end
  end

  def remove_notification
    @notification = DashboardNotification.find(params[:id])
    respond_to do |format|
      if @notification.destroy
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
    respond_to do |format|
      format.html {render :layout => "dashboard"}
    end
  end
end