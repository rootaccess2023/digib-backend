ActiveAdmin.register BarangayClearance do
  menu priority: 3, label: "Barangay Clearances"
  
  # Permit parameters that can be edited
  permit_params :purpose, :status, :remarks, :fee_amount, :fee_paid,
                :government_id_type, :cedula_number, :cedula_issued_date, :cedula_issued_at
  
  # Index view
  index do
    selectable_column
    id_column
    column :reference_number
    column :user do |clearance|
      if clearance.user
        link_to "#{clearance.user.first_name} #{clearance.user.last_name}", admin_user_path(clearance.user)
      end
    end
    column :purpose
    column :status do |clearance|
      status_tag clearance.status, 
                 class: case clearance.status
                        when 'pending' then 'warning'
                        when 'processing' then 'blue'
                        when 'approved' then 'green'
                        when 'completed' then 'green'
                        when 'rejected' then 'red'
                        end
    end
    column :created_at
    column :fee_amount do |clearance|
      number_to_currency(clearance.fee_amount, unit: '₱')
    end
    column :fee_paid do |clearance|
      status_tag clearance.fee_paid ? 'Paid' : 'Unpaid', 
                 class: clearance.fee_paid ? 'green' : 'red'
    end
    actions
  end
  
  # Show view
  show do
    attributes_table do
      row :reference_number
      row :user do |clearance|
        link_to "#{clearance.user.first_name} #{clearance.user.last_name}", admin_user_path(clearance.user)
      end
      row :purpose
      row :status do |clearance|
        status_tag clearance.status, 
                   class: case clearance.status
                          when 'pending' then 'warning'
                          when 'processing' then 'blue'
                          when 'approved' then 'green'
                          when 'completed' then 'green'
                          when 'rejected' then 'red'
                          end
      end
      row :remarks
      row :fee_amount do |clearance|
        number_to_currency(clearance.fee_amount, unit: '₱')
      end
      row :fee_paid do |clearance|
        status_tag clearance.fee_paid ? 'Paid' : 'Unpaid', 
                   class: clearance.fee_paid ? 'green' : 'red'
      end
      row :government_id_type
      row :cedula_number
      row :cedula_issued_date
      row :cedula_issued_at
      row :approved_by do |clearance|
        if clearance.approved_by
          link_to "#{clearance.approved_by.first_name} #{clearance.approved_by.last_name}", admin_user_path(clearance.approved_by)
        end
      end
      row :approved_at
      row :rejected_by do |clearance|
        if clearance.rejected_by
          link_to "#{clearance.rejected_by.first_name} #{clearance.rejected_by.last_name}", admin_user_path(clearance.rejected_by)
        end
      end
      row :rejected_at
      row :created_at
      row :updated_at
    end
  end
  
  # Form
  form do |f|
    f.inputs 'Barangay Clearance Details' do
      f.input :purpose
      f.input :status, as: :select, collection: BarangayClearance.statuses.keys
      f.input :remarks
      f.input :fee_amount
      f.input :fee_paid
      f.input :government_id_type
      f.input :cedula_number
      f.input :cedula_issued_date, as: :datepicker
      f.input :cedula_issued_at
    end
    f.actions
  end
  
  # Filter
  filter :reference_number
  filter :user, collection: proc { User.all.map { |u| ["#{u.first_name} #{u.last_name}", u.id] } }
  filter :status, as: :select, collection: BarangayClearance.statuses.keys
  filter :purpose
  filter :created_at
  filter :fee_paid, as: :boolean
  
  # Sidebar
  sidebar "Clearance Status", only: :show do
    status = resource.status
    
    case status
    when "pending"
      para "This clearance request is waiting for initial review."
    when "processing"
      para "This clearance request is currently being processed."
    when "approved"
      para "This clearance has been approved and is waiting for payment/pickup."
    when "completed"
      para "This clearance has been completed and issued to the resident."
    when "rejected"
      para "This clearance request was rejected."
      para "Reason: #{resource.remarks}" if resource.remarks.present?
    end
    
    hr
    
    para do
      if status == "pending"
        button_to "Mark as Processing", "#", method: :get, class: "button"
      elsif status == "processing"
        button_to "Approve Clearance", "#", method: :get, class: "button"
        button_to "Reject Clearance", "#", method: :get, class: "button"
      elsif status == "approved"
        button_to "Mark as Completed", "#", method: :get, class: "button"
      end
    end
  end
end