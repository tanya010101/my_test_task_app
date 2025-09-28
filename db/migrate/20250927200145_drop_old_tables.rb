class DropOldTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :users
    drop_table :medical_profiles
    drop_table :bmr_results
    drop_table :pat_doc_relationships
  end
end
