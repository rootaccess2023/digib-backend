class AddProfileFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :middle_name, :string
    add_column :users, :last_name, :string
    add_column :users, :name_extension, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :gender, :string
    add_column :users, :civil_status, :string
    add_column :users, :mobile_phone, :string
  end
end
