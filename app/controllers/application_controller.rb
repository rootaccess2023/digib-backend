class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include ActionController::Cookies
  
  def welcome
    respond_to do |format|
      format.html
      format.json { render json: { message: "Welcome to the API" } }
    end
  end
end