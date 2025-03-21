# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
admin = User.find_or_initialize_by(email: 'admin@example.com')
if admin.new_record?
  admin.password = 'password'
  admin.password_confirmation = 'password'
  admin.admin = true
  admin.save!
  puts "Admin user created with email: admin@example.com and password: password"
else
  admin.update(admin: true) unless admin.admin
  puts "Admin user already exists, ensured admin status"
end