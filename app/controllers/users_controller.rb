class UsersController < ApplicationController

  before_filter :require_login, :except => [:new, :create, :activate]


  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end

  def new
    if params[:school]
      if current_user
        redirect_to user_path(current_user)
      else
        @school = School.find(params[:school])
        @user = User.new
        respond_to do |format|
          format.html
          format.json { render json: @user }
        end
      end
    else
      redirect_to root_path
    end
  end

  def edit
    @school = current_user.school
    @user = User.find(params[:id])
  end

  def create  
    @school = School.find(params[:user][:school_id])
    @email_postfix = @school.present? ? "#{@school.email_postfix }" : nil
    unless params[:user][:email].blank?
      params[:user][:email] =  "#{params[:user][:email]}"+"@"+"#{@email_postfix}"
    end
    @user = User.new(params[:user])
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

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
end