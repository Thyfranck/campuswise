class StaticController < ApplicationController

  def home
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def public_find_books
    @school = School.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
end
