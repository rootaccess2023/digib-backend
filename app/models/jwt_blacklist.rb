class JWTBlacklist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  
  self.table_name = 'jwt_blacklists'
end