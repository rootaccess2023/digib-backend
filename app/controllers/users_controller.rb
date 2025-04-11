module Api
  class UsersController < BaseController
    before_action :authenticate_with_jwt
    
    # Update user profile
    def update_profile
      # Find the user's residential address or build a new one if it doesn't exist
      if current_user.residential_address.nil?
        current_user.build_residential_address(residential_address_params)
      else
        current_user.residential_address.update(residential_address_params)
      end
      
      # Update the user attributes
      if current_user.update(user_params)
        render json: current_user.as_json(include: :residential_address)
      else
        render json: { error: current_user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # Change password
    def change_password
      # Check if current password is correct
      unless current_user.valid_password?(params[:user][:current_password])
        return render json: { error: "Current password is incorrect" }, status: :unprocessable_entity
      end
      
      # Update with new password
      if current_user.update(password_params)
        render json: { message: "Password updated successfully" }
      else
        render json: { error: current_user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    private
    
    def user_params
      params.require(:user).permit(
        :first_name, :middle_name, :last_name, :name_extension,
        :date_of_birth, :gender, :civil_status, :mobile_phone
      )
    end
    
    def residential_address_params
      params.require(:user).require(:residential_address).permit(
        :house_number, :street_name, :purok, :barangay, :city, :province
      )
    end
    
    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end