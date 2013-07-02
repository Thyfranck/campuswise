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
    if @user = User.authenticate(params[:email], params[:password])
      if @user.phone.blank?
        session[:user_tmp_id] = @user.id
        redirect_to new_phone_user_path(@user), :notice => "Please give your mobile phone number."
      elsif @user.phone_verified == "verified"
        @school = @user.school
        auto_login(@user)
        if session[:referer].present?
          puts "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
          puts session[:referer]
          path = session.delete(:referer)
        else
          path = dashboard_path
        end
        redirect_back_or_to path, :notice => "Logged in"
      else
        session[:user_tmp_id] = @user.id
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
