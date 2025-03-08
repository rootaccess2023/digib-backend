class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  private
  
  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: resource
      }
    else
      render json: {
        status: { code: 422, message: "User couldn't be created. #{resource.errors.full_messages.join(', ')}" }
      }, status: :unprocessable_entity
    end
  end
end