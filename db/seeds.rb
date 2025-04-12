# Clear all existing user accounts
puts "Deleting all existing user accounts..."
User.destroy_all
puts "All existing accounts have been deleted."

# Create the main admin account
admin = User.new(
  email: 'admin@digib.com',
  password: 'password',
  password_confirmation: 'password',
  admin: true,
  first_name: 'System',
  last_name: 'Administrator',
  barangay_position: 'barangay_captain',  # Assign as Barangay Captain
  verification_status: 'verified',
  
  # Add required fields
  date_of_birth: '1980-01-01',  # Example birthdate
  gender: 'male',               # Choose appropriate gender
  civil_status: 'single',       # Choose appropriate civil status
)

# Create a residential address for the admin
admin.build_residential_address(
  barangay: 'Example Barangay',
  city: 'Example City',
  province: 'Example Province'
)

if admin.save
  puts "Main admin account created successfully:"
  puts "Email: admin@digib.com"
  puts "Password: password"
  puts "Role: Admin + Barangay Captain"
else
  puts "Failed to create admin account:"
  puts admin.errors.full_messages
end