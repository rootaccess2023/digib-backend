module Api
  class AdminController < BaseController
    before_action :authenticate_with_jwt
    before_action :require_admin
    
    # Get all users (admin only)
    def users
      @users = User.all
      render json: @users.as_json(include: :residential_address)
    end
    
    # Get specific user (admin only)
    def show_user
      @user = User.find(params[:id])
      render json: @user.as_json(include: :residential_address)
    end
    
    # Toggle admin role for a user
    def toggle_admin
      @user = User.find(params[:id])
      
      # Prevent admins from revoking their own admin privileges
      if @user.id == current_user.id && @user.admin
        return render json: { error: "Cannot revoke your own admin privileges" }, status: :forbidden
      end
      
      @user.update(admin: !@user.admin)
      render json: @user.as_json(include: :residential_address)
    end
    
    # Get dashboard statistics
    def dashboard_stats
      # Total users count
      total_users = User.count
      
      # Gender distribution
      male_count = User.where(gender: 'male').count
      female_count = User.where(gender: 'female').count
      other_gender_count = User.where.not(gender: [nil, '', 'male', 'female']).count
      
      # Civil status distribution
      civil_status_distribution = User.group(:civil_status).count
      
      # Age distribution
      age_distribution = calculate_age_distribution
      
      # Top barangays
      top_barangays = calculate_top_locations('barangay')
      
      # Top cities
      top_cities = calculate_top_locations('city')
      
      # Recent registrations
      recent_registrations = User.order(created_at: :desc).limit(5).as_json(include: :residential_address)
      
      # Combine all stats
      stats = {
        total_users: total_users,
        gender_distribution: {
          male: male_count,
          female: female_count,
          other: other_gender_count
        },
        civil_status_distribution: civil_status_distribution,
        age_distribution: age_distribution,
        top_barangays: top_barangays,
        top_cities: top_cities,
        recent_registrations: recent_registrations
      }
      
      render json: stats
    end
    
    private
    
    def calculate_age_distribution
      # Define age ranges
      ranges = {
        under18: { min: 0, max: 17 },
        age18to25: { min: 18, max: 25 },
        age26to35: { min: 26, max: 35 },
        age36to45: { min: 36, max: 45 },
        age46to60: { min: 46, max: 60 },
        over60: { min: 61, max: 200 }
      }
      
      distribution = ranges.keys.index_with { |_| 0 }
      
      User.where.not(date_of_birth: nil).find_each do |user|
        age = calculate_age(user.date_of_birth)
        
        ranges.each do |range_key, range_values|
          if age >= range_values[:min] && age <= range_values[:max]
            distribution[range_key] += 1
            break
          end
        end
      end
      
      distribution
    end
    
    def calculate_age(date_of_birth)
      today = Date.today
      age = today.year - date_of_birth.year
      age -= 1 if today < date_of_birth + age.years # Adjust age if birthday hasn't occurred yet this year
      age
    end
    
    def calculate_top_locations(location_type)
      ResidentialAddress.where.not(location_type => [nil, '']).group(location_type).count.sort_by { |_, count| -count }.take(5)
    end
    
    def require_admin
      unless current_user&.admin
        render json: { error: "Admin access required" }, status: :forbidden
      end
    end
  end
end