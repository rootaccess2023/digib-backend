class AddBarangayPositionsAndVerificationToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add barangay position field
    add_column :users, :barangay_position, :string
    
    # Add verification status
    add_column :users, :verification_status, :string, default: 'unverified'
    
    # Add verification details
    add_column :users, :verified_at, :datetime
    add_column :users, :verified_by_id, :bigint
    add_index :users, :verified_by_id
  end
end