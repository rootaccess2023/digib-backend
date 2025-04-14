class DropBarangayClearancesTable < ActiveRecord::Migration[7.1]
  def up
    # First remove foreign key constraints
    remove_foreign_key :barangay_clearances, column: :approved_by_id
    remove_foreign_key :barangay_clearances, column: :rejected_by_id
    remove_foreign_key :barangay_clearances, column: :user_id
    
    # Then drop the table
    drop_table :barangay_clearances
  end

  def down
    # Re-create the table if you need to roll back this migration
    create_table :barangay_clearances do |t|
      t.references :user, null: false, foreign_key: true
      t.string :purpose, null: false
      t.string :status, default: 'pending'
      t.text :remarks
      t.string :reference_number
      t.decimal :fee_amount, precision: 8, scale: 2
      t.boolean :fee_paid, default: false
      t.string :government_id_type
      t.string :cedula_number
      t.date :cedula_issued_date
      t.string :cedula_issued_at
      t.references :approved_by, foreign_key: { to_table: :users }, null: true
      t.datetime :approved_at
      t.references :rejected_by, foreign_key: { to_table: :users }, null: true
      t.datetime :rejected_at

      t.timestamps
    end
    
    add_index :barangay_clearances, :reference_number, unique: true
    add_index :barangay_clearances, :status
  end
end