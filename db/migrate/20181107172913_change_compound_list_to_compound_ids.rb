class ChangeCompoundListToCompoundIds < ActiveRecord::Migration[5.2]
  def change
    rename_column :spotlight_resources, :compound_list, :compound_ids
    change_column :spotlight_resources, :compound_ids, :text
  end
end
