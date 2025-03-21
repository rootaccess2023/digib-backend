# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    
    protected
    
    def authenticate_with_jwt
      token = request.headers['Authorization']&.split(' ')&.last
      if token.nil?
        render json: { error: 'No token provided' }, status: :unauthorized
        return false
      end
      
      begin
        decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
        user_id = decoded_token[0]['sub']
        @current_user = User.find(user_id)
        return true
      rescue JWT::DecodeError
        render json: { error: 'Invalid token' }, status: :unauthorized
        return false
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
        return false
      end
    end
    
    def current_user
      @current_user
    end
  end
end