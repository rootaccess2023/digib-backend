module Api
  class DocumentRequestsController < BaseController
    before_action :authenticate_with_jwt
    before_action :set_document_request, only: [:show, :update, :destroy]
    before_action :require_admin_or_barangay_official, only: [:index_all, :update_status]
    before_action :require_verified_user, only: [:create]
    
    # GET /api/document_requests
    # Returns all document requests for current user
    def index
      @document_requests = current_user.document_requests.order(created_at: :desc)
      render json: @document_requests
    end
    
    # GET /api/document_requests/all
    # Admin/Official only - Returns all document requests
    def index_all
      @document_requests = DocumentRequest.includes(:user, :approved_by, :rejected_by)
                                         .order(created_at: :desc)
                                         
      # Filter by status if provided
      if params[:status].present?
        @document_requests = @document_requests.where(status: params[:status])
      end
      
      # Filter by document type if provided
      if params[:document_type].present?
        @document_requests = @document_requests.where(document_type: params[:document_type])
      end
      
      render json: @document_requests
    end
    
    # GET /api/document_requests/:id
    def show
      # Check if the current user owns the request or is an admin/official
      unless authorized_for_document_request?(@document_request)
        return render json: { error: "You are not authorized to view this document request" }, status: :forbidden
      end
      
      render json: @document_request
    end
    
    # POST /api/document_requests
    def create
      @document_request = current_user.document_requests.new(document_request_params)
      
      if @document_request.save
        render json: @document_request, status: :created
      else
        render json: { error: @document_request.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # PATCH/PUT /api/document_requests/:id/status
    def update_status
      @document_request = DocumentRequest.find(params[:id])
      
      case params[:status]
      when 'processing'
        @document_request.mark_as_processing!(current_user.id)
        render json: @document_request
      when 'approved'
        @document_request.approve!(current_user.id)
        render json: @document_request
      when 'completed'
        @document_request.complete!
        render json: @document_request
      when 'rejected'
        # Require remarks for rejection
        if params[:remarks].blank?
          return render json: { error: "Remarks are required for rejection" }, status: :unprocessable_entity
        end
        
        @document_request.reject!(current_user.id, params[:remarks])
        render json: @document_request
      else
        render json: { error: "Invalid status" }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
    
    # PATCH/PUT /api/document_requests/:id
    def update
      # Only allow updating if the request is pending and belongs to the current user
      unless @document_request.pending? && @document_request.user_id == current_user.id
        return render json: { error: "Cannot update this document request" }, status: :forbidden
      end
      
      if @document_request.update(document_request_params)
        render json: @document_request
      else
        render json: { error: @document_request.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end
    end
    
    # DELETE /api/document_requests/:id
    def destroy
      # Only allow deletion if the request is pending and belongs to the current user
      unless @document_request.pending? && @document_request.user_id == current_user.id
        return render json: { error: "Cannot delete this document request" }, status: :forbidden
      end
      
      @document_request.destroy
      head :no_content
    end
    
    private
    
    def set_document_request
      @document_request = DocumentRequest.find(params[:id])
    end
    
    def document_request_params
      params.require(:document_request).permit(
        :document_type,
        :purpose,
        document_data: {}
      )
    end
    
    def authorized_for_document_request?(document_request)
      current_user.admin? || 
      current_user.can_process_clearances? || 
      document_request.user_id == current_user.id
    end
    
    def require_admin_or_barangay_official
      unless current_user.admin? || current_user.can_process_clearances?
        render json: { error: "Admin or Barangay Official access required" }, status: :forbidden
      end
    end
    
    def require_verified_user
      unless current_user.verified?
        render json: { error: "Your account must be verified to submit document requests" }, status: :forbidden
      end
    end
  end
end