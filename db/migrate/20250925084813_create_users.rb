# Для таблицы Users, в которой хранится на данный момент ФИО всех пользователей(пациентов и врачей) и их роль в системе
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    # Создаем ENUM roles
    enable_extension 'citext' unless extension_enabled?('citext')
    execute <<-SQL
      DO $$
      BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'roles') THEN
          CREATE TYPE roles AS ENUM ('doctor', 'patient');
        END IF;
      END $$;
    SQL

    # Создаем таблицу users
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :middle_name
      t.column :role, :roles, null: false, default: 'doctor' # Указываем тип ENUM

    end
  end
end