class CreateResidentialAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :residential_addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :house_number
      t.string :street_name
      t.string :purok
      t.string :barangay
      t.string :city
      t.string :province

      t.timestamps
    end
  end
end
