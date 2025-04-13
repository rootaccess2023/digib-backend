class DocumentRequest < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :rejected_by, class_name: 'User', optional: true
  
  # Valid document types
  DOCUMENT_TYPES = [
    'barangay_clearance',
    'certificate_of_residency',
    'certificate_of_indigency',
    'barangay_id',
    'certificate_of_good_moral_character',
    'endorsement_letter',
    'blotter_record',
    'business_clearance'
  ]
  
  # Status enum
  enum status: {
    pending: 'pending',
    processing: 'processing',
    approved: 'approved',
    rejected: 'rejected',
    completed: 'completed'
  }
  
  validates :document_type, presence: true, inclusion: { in: DOCUMENT_TYPES }
  validates :purpose, presence: true
  validates :reference_number, uniqueness: true, allow_nil: true
  
  # Callbacks
  before_create :generate_reference_number
  before_create :set_default_fee

  # Generate unique reference number
  def generate_reference_number
    return if reference_number.present?

    loop do
      prefix = case document_type
              when 'barangay_clearance' then 'BC'
              when 'certificate_of_residency' then 'CR'
              when 'certificate_of_indigency' then 'CI'
              when 'barangay_id' then 'ID'
              when 'certificate_of_good_moral_character' then 'GMC'
              when 'endorsement_letter' then 'EL'
              when 'blotter_record' then 'BR'
              when 'business_clearance' then 'BBC'
              else 'DOC'
              end
      
      date_part = Date.today.strftime('%Y%m%d')
      random_part = SecureRandom.alphanumeric(6).upcase
      self.reference_number = "#{prefix}-#{date_part}-#{random_part}"
      break unless DocumentRequest.exists?(reference_number: reference_number)
    end
  end
  
  # Set default fee based on document type
  def set_default_fee
    self.fee_amount ||= case document_type
                        when 'barangay_clearance' then 50.00
                        when 'certificate_of_residency' then 30.00
                        when 'certificate_of_indigency' then 0.00
                        when 'barangay_id' then 75.00
                        when 'certificate_of_good_moral_character' then 50.00
                        when 'endorsement_letter' then 0.00
                        when 'blotter_record' then 75.00
                        when 'business_clearance' then 200.00
                        else 50.00
                        end
  end
  
  # Processing workflow methods
  def mark_as_processing!(processor_id)
    update!(status: :processing)
  end
  
  def approve!(approver_id)
    update!(
      status: :approved,
      approved_by_id: approver_id,
      approved_at: Time.current
    )
  end
  
  def complete!
    update!(
      status: :completed,
      fee_paid: true
    )
  end
  
  def reject!(rejector_id, remarks)
    update!(
      status: :rejected,
      rejected_by_id: rejector_id,
      rejected_at: Time.current,
      remarks: remarks
    )
  end
  
  # Return JSON-friendly data
  def as_json(options = {})
    super(options.merge(
      include: {
        user: { only: [:id, :email, :first_name, :last_name] },
        approved_by: { only: [:id, :email, :first_name, :last_name] },
        rejected_by: { only: [:id, :email, :first_name, :last_name] }
      },
      methods: [:days_ago]
    ))
  end
  
  # Days since request was created
  def days_ago
    ((Time.current - created_at) / 1.day).floor
  end
  
  # For ActiveAdmin
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "reference_number", "purpose", "status", "fee_amount", "fee_paid", "user_id", "document_type"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["user", "approved_by", "rejected_by"]
  end
end