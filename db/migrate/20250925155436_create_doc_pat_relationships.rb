class CreateDocPatRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :doc_pat_relationships do |t|
      t.integer :patient_id, null: false
      t.integer :doctor_id, null: false
      
    end

    
    add_foreign_key :doc_pat_relationships, :patients, column: :patient_id
    add_foreign_key :doc_pat_relationships, :doctors, column: :doctor_id
  end
end
