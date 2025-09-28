class FixCascadeDeletionForDocPatRelationships < ActiveRecord::Migration[8.0]
  def change
    # Удаляем старые внешние ключи
    remove_foreign_key :doc_pat_relationships, :patients
    remove_foreign_key :doc_pat_relationships, :doctors

    # Добавляем новые внешние ключи с каскадным удалением
    add_foreign_key :doc_pat_relationships, :patients, column: :patient_id, on_delete: :cascade
    add_foreign_key :doc_pat_relationships, :doctors, column: :doctor_id, on_delete: :cascade
  end
end
