class ResultBmr < ApplicationRecord
  belongs_to :patient
  self.table_name = 'results_bmr'

  enum :formula_used , { mifflin_sant_geora: 'mifflin_santGeora', harris_benedict: 'harris_benedict' }, prefix: :formula_used


  validates :formula_used, presence: true
  validates :result_value, numericality: { greater_than_or_equal_to: 0 }
end