class CreateResultsBmr < ActiveRecord::Migration[8.0]
  def change
    # Для реализации enum
    execute <<-SQL
      CREATE TYPE formula_type_bmr AS ENUM ('mifflin_santGeora', 'harris_benedict');
    SQL

    # Создаем таблицу bmr_results
    create_table :results_bmr do |t|
      t.references :patient, foreign_key: {on_delete: :cascade}, null: false
      t.column :formula_used, :formula_type_bmr, null: false 
      t.decimal :result_value, precision: 10, scale: 2
      t.datetime :calculate_at, null: false
    end
  end
end
