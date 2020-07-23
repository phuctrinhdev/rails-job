class AddColumnsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :image, :string
    add_column :users, :cv, :string
  end
end
