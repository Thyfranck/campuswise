class SessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]

  def new
    if current_user
      redirect_to user_path(current_user)
    else
      if params[:school]
        @school = School.find(params[:school])
        session[:school_id] = @school.id
      end
      @user = User.new
    end
    
  end

  def create
    if @user = User.authenticate(params[:email],params[:password])
      if @user.phone_verified == "verified"
        @school = @user.school
        auto_login(@user)
        redirect_back_or_to dashboard_path, :notice => "Logged in"
      else
        redirect_to sms_verification_user_path(@user)
      end
    else     
      if @user = User.authenticate_without_active_check(params[:email],params[:password])
        flash[:alert] = "Please check your Email to activate your account."
      else
        flash[:alert] = "Email or Password was invalid!"
      end
      redirect_to login_path 
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end
