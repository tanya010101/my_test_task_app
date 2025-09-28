class CreatePatients < ActiveRecord::Migration[8.0]
  def change

    # Нужно, чтобы указать ENUM для пола
    execute <<-SQL
      CREATE TYPE gender_enum AS ENUM ('male', 'female');
    SQL

    # Само создание таблицы patients
    create_table :patients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :middle_name
      t.date :date_of_birth, null: false
      t.float :height
      t.float :weight
      t.column :gender, :gender_enum, null: false

      # Индекс, чтобы назначить уникальность на набор полей
      t.index [:first_name, :last_name, :middle_name, :date_of_birth], unique: true

      t.timestamps
    end
  end
end
