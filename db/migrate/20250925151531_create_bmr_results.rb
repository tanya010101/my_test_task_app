class CreateBmrResults < ActiveRecord::Migration[8.0]
  def change
    # Для реализации enum
    execute <<-SQL
      CREATE TYPE formula_type AS ENUM ('harris-benedict', 'mifflin-st-jeor');
    SQL

    # Создаем таблицу bmr_results
    create_table :bmr_results do |t|
      t.references :patient, foreign_key: true
      t.column :formula_used, :formula_type, null: false 
      t.decimal :result_value, precision: 10, scale: 2
      t.datetime :calculate_at, null: false # Используем datetime для отдельного поля
    end
  end
end