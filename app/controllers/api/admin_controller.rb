# app/controllers/api/admin_controller.rb
module Api
  class AdminController < BaseController
    before_action :authenticate_with_jwt
    before_action :require_admin
    
    # Get all users (admin only)
    def users
      @users = User.all
      render json: @users.as_json
    end
    
    # Toggle admin role for a user
    def toggle_admin
      @user = User.find(params[:id])
      
      # Prevent admins from revoking their own admin privileges
      if @user.id == current_user.id && @user.admin
        return render json: { error: "Cannot revoke your own admin privileges" }, status: :forbidden
      end
      
      @user.update(admin: !@user.admin)
      render json: @user.as_json
    end
    
    private
    
    def require_admin
      unless current_user&.admin
        render json: { error: "Admin access required" }, status: :forbidden
      end
    end
  end
end