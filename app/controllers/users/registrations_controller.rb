class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  def create
    build_resource(sign_up_params)
    resource.build_residential_address(residential_address_params)
    
    resource.save
    
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: resource,
        token: resource.generate_jwt
      }
    else
      render json: {
        status: { code: 422, message: "User couldn't be created. #{resource.errors.full_messages.join(', ')}" }
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      :first_name, :middle_name, :last_name, :name_extension,
      :date_of_birth, :gender, :civil_status, :mobile_phone
    )
  end
  
  def residential_address_params
    params.require(:user).require(:residential_address).permit(
      :house_number, :street_name, :purok, :barangay, :city, :province
    )
  end
end