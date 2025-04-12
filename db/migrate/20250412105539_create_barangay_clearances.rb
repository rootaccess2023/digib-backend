class CreateBarangayClearances < ActiveRecord::Migration[7.1]
  def change
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