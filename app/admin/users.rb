ActiveAdmin.register User do
  # Permit these parameters for creating and updating users
  permit_params :email, :password, :password_confirmation

  # Don't forget to add ransackable attributes for search functionality
  controller do
    def find_resource
      User.find_by(id: params[:id])
    end
  end

  # Define which attributes are shown in the index view
  index do
    selectable_column
    id_column
    column :email
    column :created_at
    actions
  end

  # Define the filter options in the sidebar
  filter :email
  filter :created_at

  # Define the form for creating and editing users
  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # Add necessary ransackable attributes to your User model
  # Add this code to your User model:
  # def self.ransackable_attributes(auth_object = nil)
  #   ["created_at", "email", "id", "updated_at"]
  # end
  #
  # def self.ransackable_associations(auth_object = nil)
  #   []
  # end
end