class CreateMedicalProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :medical_profiles do |t|
      t.integer :user_id
      t.date :date_of_birth
      t.integer :height
      t.float :weight
      t.string :gender

      t.timestamps
    end
  end
end
