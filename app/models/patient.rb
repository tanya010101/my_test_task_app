class Patient < ApplicationRecord
    enum :gender , { male: "male", female: "female"}, prefix: :gender

    validates :first_name, presence: true, format: { with: /\A[\p{Cyrillic}\-\s]+\z/, message: "должно содержать только кириллицу" }
    validates :last_name, presence: true, format: { with: /\A[\p{Cyrillic}\-\s]+\z/, message: "должно содержать только кириллицу" }
    validates :middle_name, allow_blank: true, format: { with: /\A[\p{Cyrillic}\-\s]*\z/, message: "должно содержать только кириллицу" }, if: -> { middle_name.present? }
    validates :date_of_birth, presence: true
    validates :gender, inclusion: { in: genders.keys }, presence: true
    validates_uniqueness_of :first_name, scope: [:last_name, :middle_name, :date_of_birth]

    # Ограничение на отсутсвие отрицательных чисел
    validates :height, numericality: { greater_than_or_equal_to: 0, allow_nil: true } 
    validates :weight, numericality: { greater_than_or_equal_to: 0, allow_nil: true }


    # Ограничение, что минимальная дата рождения - сегодня
    validate :validate_date_of_birth

    def validate_date_of_birth
        return if date_of_birth.blank?
        errors.add(:date_of_birth, "не может быть позже сегодняшней даты") if date_of_birth > Date.current
    end

    def full_name
     "#{last_name} #{first_name} #{middle_name}".strip
    end

  
    has_many :doc_pat_relationships, dependent: :delete_all
    has_many :doctors, through: :doc_pat_relationships

    has_many :result_bmrs, dependent: :destroy
end
