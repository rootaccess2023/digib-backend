# app/controllers/api/auth_controller.rb
module Api
  class AuthController < BaseController
    skip_before_action :verify_authenticity_token, if: :json_request?
    
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
      if authenticate_with_jwt
        render json: current_user.as_json
      end
    end
    
    def logout
      # Your existing logout logic
      render json: {
        status: { code: 200, message: 'Logged out successfully.' }
      }
    end
    
    private
    
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
    
    def json_request?
      request.format.json?
    end
  end
end