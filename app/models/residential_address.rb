class ResidentialAddress < ApplicationRecord
  belongs_to :user
  
  validates :barangay, presence: true
  validates :city, presence: true
  validates :province, presence: true
  
  def self.ransackable_attributes(auth_object = nil)
    ["barangay", "city", "house_number", "province", "purok", "street_name"]
  end
end