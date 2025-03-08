# app/controllers/api/auth_controller.rb
class Api::AuthController < ApplicationController
  def signup
    user = User.new(user_params)
    
    if user.save
      token = user.generate_jwt
      render json: { 
        status: { code: 200, message: 'Signed up successfully.' },
        data: user.as_json,
        token: token
      }
    else
      render json: { 
        status: { code: 422, message: "User couldn't be created. #{user.errors.full_messages.join(', ')}" }
      }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:user][:email])
    
    if user && user.valid_password?(params[:user][:password])
      token = user.generate_jwt
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: user.as_json,
        token: token
      }
    else
      render json: {
        status: { code: 401, message: "Invalid email or password." }
      }, status: :unauthorized
    end
  end
  
  def me
    token = request.headers['Authorization']&.split(' ')&.last
    if token.nil?
      render json: { error: 'No token provided' }, status: :unauthorized
      return
    end
    
    begin
      decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
      user_id = decoded_token[0]['sub']
      user = User.find(user_id)
      render json: user
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :not_found
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end