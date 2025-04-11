class User < ApplicationRecord
  # Include default devise modules
  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable
  
  # Residential address association
  has_one :residential_address, dependent: :destroy
  accepts_nested_attributes_for :residential_address
  
  # Validations for profile fields
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validates :civil_status, presence: true
  
  # Set JTI before creating user
  before_create :set_jti
  
  # Gender options
  enum gender: { male: 'male', female: 'female', other: 'other' }
  
  # Civil status options
  enum civil_status: { 
    single: 'single', 
    married: 'married', 
    widowed: 'widowed', 
    separated: 'separated', 
    divorced: 'divorced'
  }
  
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
    user_data = super(options.merge(
      except: [:encrypted_password, :jti, :created_at, :updated_at],
      include: [:residential_address]
    ))
    user_data.merge({admin: admin})
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "updated_at", "first_name", "last_name"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["residential_address"]
  end
  
  private
  
  def set_jti
    self.jti = SecureRandom.uuid
  end
end