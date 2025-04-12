module Api
  class ClearancesController < BaseController
    before_action :authenticate_with_jwt
    before_action :set_clearance, only: [:show, :update, :destroy]
    before_action :require_admin_or_barangay_official, only: [:index_all, :update_status]
    before_action :require_verified_user, only: [:create]
    
    # GET /api/clearances
    # Returns all clearances for current user
    def index
      @clearances = current_user.barangay_clearances.order(created_at: :desc)
      render json: @clearances
    end
    
    # GET /api/clearances/all
    # Admin/Official only - Returns all clearances
    def index_all
      @clearances = BarangayClearance.includes(:user, :approved_by, :rejected_by)
                                     .order(created_at: :desc)
                                     
      # Filter by status if provided
      if params[:status].present?
        @clearances = @clearances.where(status: params[:status])
      end
      
      render json: @clearances
    end
    
    # GET /api/clearances/:id
    def show
      # Check if the current user owns the clearance or is an admin/official
      unless authorized_for_clearance?(@clearance)
        return render json: { error: "You are not authorized to view this clearance" }, status: :forbidden
      end
      
      render json: @clearance
    end
    
    # POST /api/clearances
    def create
      @clearance = current_user.barangay_clearances.new(clearance_params)
      
      if @clearance.save
        render json: @clearance, status: :created
      else
        render json: { error: @clearance.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # PATCH/PUT /api/clearances/:id/status
    def update_status
      @clearance = BarangayClearance.find(params[:id])
      
      case params[:status]
      when 'processing'
        @clearance.mark_as_processing!(current_user.id)
        render json: @clearance
      when 'approved'
        @clearance.approve!(current_user.id)
        render json: @clearance
      when 'completed'
        @clearance.complete!
        render json: @clearance
      when 'rejected'
        # Require remarks for rejection
        if params[:remarks].blank?
          return render json: { error: "Remarks are required for rejection" }, status: :unprocessable_entity
        end
        
        @clearance.reject!(current_user.id, params[:remarks])
        render json: @clearance
      else
        render json: { error: "Invalid status" }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
    
    # PATCH/PUT /api/clearances/:id
    def update
      # Only allow updating if the clearance is pending and belongs to the current user
      unless @clearance.pending? && @clearance.user_id == current_user.id
        return render json: { error: "Cannot update this clearance" }, status: :forbidden
      end
      
      if @clearance.update(clearance_params)
        render json: @clearance
      else
        render json: { error: @clearance.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # DELETE /api/clearances/:id
    def destroy
      # Only allow deletion if the clearance is pending and belongs to the current user
      unless @clearance.pending? && @clearance.user_id == current_user.id
        return render json: { error: "Cannot delete this clearance" }, status: :forbidden
      end
      
      @clearance.destroy
      head :no_content
    end
    
    private
    
    def set_clearance
      @clearance = BarangayClearance.find(params[:id])
    end
    
    def clearance_params
      params.require(:clearance).permit(
        :purpose, 
        :government_id_type, 
        :cedula_number, 
        :cedula_issued_date, 
        :cedula_issued_at
      )
    end
    
    def authorized_for_clearance?(clearance)
      current_user.admin? || 
      current_user.can_process_clearances? || 
      clearance.user_id == current_user.id
    end
    
    def require_admin_or_barangay_official
      unless current_user.admin? || current_user.can_process_clearances?
        render json: { error: "Admin or Barangay Official access required" }, status: :forbidden
      end
    end
    
    def require_verified_user
      unless current_user.verified?
        render json: { error: "Your account must be verified to request a barangay clearance" }, status: :forbidden
      end
    end
  end
end