class ApplicationController < ActionController::Base
  protect_from_forgery
  require 'will_paginate/array'
  def current_school
    @school = School.first if School.count == 1
    @school = current_user.school if current_user
    @school ||= session[:school_id].present? ? School.find(session[:school_id]) : nil
  end

  helper_method :current_school

  private
  def not_authenticated
    redirect_to login_path
    flash[:alert] = "First log in to view this page."
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to dashboard_url, :alert => exception.message
  end
end
