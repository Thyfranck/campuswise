class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def current_school
    @school = current_user.school if current_user
    @school ||= session[:school_id].present? ? School.find(session[:school_id]) : nil
  end

  helper_method :current_school

  private
  def not_authenticated
    redirect_to login_path
    flash[:alert] = "First log in to view this page."
  end
end
