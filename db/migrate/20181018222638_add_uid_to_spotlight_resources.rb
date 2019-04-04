class AddUidToSpotlightResources < ActiveRecord::Migration[5.2]
  def change
    add_column :spotlight_resources, :uid, :string
  end
end
