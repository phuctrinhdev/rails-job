class AddForeignToCities < ActiveRecord::Migration[6.0]
  def change
    add_column :cities, :foreign, :boolean, default: false
  end
end
