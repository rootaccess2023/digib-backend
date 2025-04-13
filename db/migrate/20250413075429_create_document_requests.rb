class CreateDocumentRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :document_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :document_type, null: false
      t.string :purpose, null: false
      t.string :status, default: 'pending'
      t.text :remarks
      t.string :reference_number
      t.decimal :fee_amount, precision: 8, scale: 2
      t.boolean :fee_paid, default: false
      t.jsonb :document_data # Stores document-specific data
      t.references :approved_by, foreign_key: { to_table: :users }, null: true
      t.datetime :approved_at
      t.references :rejected_by, foreign_key: { to_table: :users }, null: true
      t.datetime :rejected_at

      t.timestamps
    end
    
    add_index :document_requests, :reference_number, unique: true
    add_index :document_requests, :status
    add_index :document_requests, :document_type
  end
end
