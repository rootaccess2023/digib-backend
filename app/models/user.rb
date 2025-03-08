# app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Set JTI before creating user
  before_create :set_jti
  
  # Generate JWT token
  def generate_jwt
    JWT.encode({
      id: id,
      sub: id,
      exp: 1.day.from_now.to_i
    }, Rails.application.credentials.secret_key_base)
  end
  
  # Return JSON-friendly user data
  def as_json(options = {})
    super(options.merge(except: [:encrypted_password, :jti, :created_at, :updated_at]))
  end
  
  private
  
  def set_jti
    self.jti = SecureRandom.uuid
  end
end