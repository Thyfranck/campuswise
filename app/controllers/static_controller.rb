class StaticController < ApplicationController

  def home
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def public_find_books
    if params[:id]
    @school = School.find(params[:id])
    respond_to do |format|
      format.html
    end
    else
      redirect_to root_path
    end
  end
end
