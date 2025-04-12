class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Residential address association
  has_one :residential_address, dependent: :destroy
  accepts_nested_attributes_for :residential_address
  
  # Validation for profile fields
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validates :civil_status, presence: true
  
  # Verification association
  belongs_to :verified_by, class_name: 'User', optional: true
  
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
  
  # Barangay position options
  enum barangay_position: {
    position_none: 'position_none',
    barangay_captain: 'barangay_captain',
    barangay_kagawad: 'barangay_kagawad',
    sk_chairperson: 'sk_chairperson',
    barangay_secretary: 'barangay_secretary',
    barangay_treasurer: 'barangay_treasurer'
  }, _default: 'position_none'
  
  # Verification status options
  enum verification_status: {
    unverified: 'unverified',
    pending: 'pending',
    verified: 'verified',
    rejected: 'rejected'
  }, _default: 'pending'
  
  # Generate JWT token
  def generate_jwt
    JWT.encode({
      id: id,
      sub: id,
      admin: admin,
      barangay_position: barangay_position,
      verification_status: verification_status,
      exp: 1.day.from_now.to_i
    }, ENV['DEVISE_JWT_SECRET_KEY'])
  end
  
  # Check if user is barangay captain
  def barangay_captain?
    barangay_position == 'barangay_captain'
  end
  
  # Check if user is barangay secretary
  def barangay_secretary?
    barangay_position == 'barangay_secretary'
  end
  
  # Check if user can verify accounts
  def can_verify_accounts?
    barangay_captain? || barangay_secretary?
  end
  
  # Return JSON-friendly user data
  def as_json(options = {})
    user_data = super(options.merge(
      except: [:encrypted_password, :jti, :created_at, :updated_at],
      include: [:residential_address]
    ))
    user_data.merge({
      admin: admin,
      can_verify_accounts: can_verify_accounts?
    })
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "updated_at", "first_name", "last_name", "barangay_position", "verification_status"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["residential_address", "verified_by"]
  end
  
  private
  
  def set_jti
    self.jti = SecureRandom.uuid
  end
end