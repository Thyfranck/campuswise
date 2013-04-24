class StaticController < ApplicationController

  def home
    @user = User.new
    respond_to do |format|
      format.html
    end
  end

  def find
    
  end
end
