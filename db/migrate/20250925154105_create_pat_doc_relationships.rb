class CreatePatDocRelationships < ActiveRecord::Migration[8.0]
  def change
    create_table :pat_doc_relationships do |t|
      t.integer :patient_id, null: false
      t.integer :doctor_id, null: false

      t.timestamps
    end

    
    add_foreign_key :pat_doc_relationships, :patients, column: :patient_id
    add_foreign_key :pat_doc_relationships, :doctors, column: :doctor_id
  end
end
