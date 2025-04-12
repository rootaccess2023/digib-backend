class BarangayClearance < ApplicationRecord
  belongs_to :user
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :rejected_by, class_name: 'User', optional: true
  
  # Status enum
  enum status: {
    pending: 'pending',
    processing: 'processing',
    approved: 'approved',
    rejected: 'rejected',
    completed: 'completed'
  }
  
  # Validations
  validates :purpose, presence: true
  validates :reference_number, uniqueness: true, allow_nil: true
  validates :government_id_type, presence: true
  validates :cedula_number, presence: true
  validates :cedula_issued_date, presence: true
  validates :cedula_issued_at, presence: true

  # Callbacks
  before_create :generate_reference_number
  before_create :set_default_fee

  # Generate unique reference number
  def generate_reference_number
    return if reference_number.present?

    loop do
      date_part = Date.today.strftime('%Y%m%d')
      random_part = SecureRandom.alphanumeric(6).upcase
      self.reference_number = "BC-#{date_part}-#{random_part}"
      break unless BarangayClearance.exists?(reference_number: reference_number)
    end
  end
  
  # Set default fee
  def set_default_fee
    self.fee_amount ||= 50.00 # Default fee is 50 pesos
  end
  
  # Mark as processing (in progress)
  def mark_as_processing!(processor_id)
    update!(status: :processing)
  end
  
  # Approve the clearance request
  def approve!(approver_id)
    update!(
      status: :approved,
      approved_by_id: approver_id,
      approved_at: Time.current
    )
  end
  
  # Mark as completed (payment received and document issued)
  def complete!
    update!(
      status: :completed,
      fee_paid: true
    )
  end
  
  # Reject the clearance request
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
    ["created_at", "reference_number", "purpose", "status", "fee_amount", "fee_paid", "user_id"]
  end
  
  def self.ransackable_associations(auth_object = nil)
    ["user", "approved_by", "rejected_by"]
  end
end