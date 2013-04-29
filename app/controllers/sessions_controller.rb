class SessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]

  def new
    if current_user
      redirect_to user_path(current_user)
    else
      @school = School.find(params[:school]) if params[:school]
      @user = User.new
    end
    
  end

  def create
    respond_to do |format|
      if @user = login(params[:email],params[:password])
        session[:school_id] = @user.school.id
        format.html { redirect_to current_user, :notice => "Logged In"}
      else
        format.html { redirect_to login_path}
        flash[:alert] = "Email or Password was invalid!"
      end
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end
