class ApplicationController < ActionController::API
  include ActionController::Cookies
  
  def welcome
    render json: { message: "Welcome to the API" }
  end
end