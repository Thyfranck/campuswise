class SessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]

  def new
    if current_user
      redirect_to user_path(current_user)
    else
      @user = User.new
    end
    
  end

  def create
    respond_to do |format|
      if @user = login(params[:email],params[:password])
        format.html { redirect_to current_user, :notice => "Logged In"}
      else
        format.html { redirect_to new_user_path}
        flash[:alert] = "Email or Password was invalid!"
      end
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end
