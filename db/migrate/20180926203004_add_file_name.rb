class AddFileName < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_resources, :file_name, :string
  end
end
