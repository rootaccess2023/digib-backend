module Api
  class BarangayAdminController < BaseController
    before_action :authenticate_with_jwt
    before_action :require_admin_or_barangay_official
    
    # Assign barangay position to user
    def assign_position
      # Only admin or barangay captain can assign positions
      unless current_user.admin? || current_user.barangay_captain?
        return render json: { error: "Unauthorized: Only admin or barangay captain can assign positions" }, status: :forbidden
      end
      
      @user = User.find(params[:id])
      
      # Validate the position parameter
      unless User.barangay_positions.keys.include?(position_params[:barangay_position])
        return render json: { error: "Invalid barangay position" }, status: :unprocessable_entity
      end
      
      # Update the user's position
      if @user.update(position_params)
        render json: @user.as_json(include: :residential_address)
      else
        render json: { error: @user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # Verify or reject a user's account
    def verify_user
      # Only admin, barangay captain, or barangay secretary can verify accounts
      unless current_user.admin? || current_user.can_verify_accounts?
        return render json: { error: "Unauthorized: Only admin, barangay captain, or barangay secretary can verify accounts" }, status: :forbidden
      end
      
      @user = User.find(params[:id])
      
      # Don't allow verifying your own account
      if @user.id == current_user.id
        return render json: { error: "You cannot verify/reject your own account" }, status: :forbidden
      end
      
      # Validate the verification status parameter
      unless ['verified', 'rejected', 'pending', 'unverified'].include?(verification_params[:verification_status])
        return render json: { error: "Invalid verification status" }, status: :unprocessable_entity
      end
      
      # Prepare verification attributes
      verification_attrs = verification_params
      
      if verification_params[:verification_status] == 'verified'
        verification_attrs = verification_attrs.merge(verified_at: Time.current, verified_by_id: current_user.id)
      elsif verification_params[:verification_status] == 'unverified' || verification_params[:verification_status] == 'rejected'
        verification_attrs = verification_attrs.merge(verified_at: nil, verified_by_id: nil)
      end
      
      # Update the user's verification status
      if @user.update(verification_attrs)
        render json: @user.as_json(include: :residential_address)
      else
        render json: { error: @user.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # Get a list of users with pending verification
    def pending_verifications
      @users = User.where(verification_status: 'pending')
      render json: @users.as_json(include: :residential_address)
    end
    
    private
    
    def position_params
      params.require(:user).permit(:barangay_position)
    end
    
    def verification_params
      params.require(:user).permit(:verification_status)
    end
    
    def require_admin_or_barangay_official
      position = current_user.barangay_position
      
      unless current_user.admin? || 
             position == 'barangay_captain' || 
             position == 'barangay_secretary' || 
             position == 'barangay_kagawad' || 
             position == 'barangay_treasurer' || 
             position == 'sk_chairperson'
        render json: { error: "Admin or Barangay Official access required" }, status: :forbidden
      end
    end
  end
end