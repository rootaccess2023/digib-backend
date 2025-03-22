# app/models/user.rb
class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
  
  # Set JTI before creating user
  before_create :set_jti
  
  # Generate JWT token
  def generate_jwt
    JWT.encode({
      id: id,
      sub: id,
      admin: admin,
      exp: 1.day.from_now.to_i
    }, ENV['DEVISE_JWT_SECRET_KEY'])
  end
  
  # Return JSON-friendly user data
  def as_json(options = {})
    super(options.merge(except: [:encrypted_password, :jti, :created_at, :updated_at])).merge({admin: admin})
  end
  
  private
  
  def set_jti
    self.jti = SecureRandom.uuid
  end
end