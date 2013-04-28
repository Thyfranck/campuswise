class PasswordResetsController < ApplicationController
  skip_before_filter :require_login

  # request password reset.
  # you get here when the user entered his email in the reset password form and submitted it.
  def new
    @school = current_school
  end

  def create
    @user = User.find_by_email(params[:email])
    @user.deliver_reset_password_instructions! if @user
    redirect_to(root_path, :notice => 'Instructions have been sent to your email.')
  end

  # This is the reset password form.
  def edit
    @user = User.load_from_reset_password_token(params[:id])
    @token = params[:id]
    not_authenticated unless @user
    @school = @user.school if @user
  end

  # This action fires when the user has sent the reset password form.
  def update
    @token = params[:token]
    @user = User.load_from_reset_password_token(params[:token])
    not_authenticated unless @user
    @school = @user.school if @user
    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      redirect_to(login_path(:school => @school), :notice => 'Password was successfully updated. Use your password to login.')
    else
      render :action => "edit"
    end
  end
end