class Doctor < ApplicationRecord
    #Проверка обязательных полей
    validates :first_name, presence: true
    validates :last_name, presence: true

    #Проверка, что содержит только буквы кириллицы
    validates_format_of :first_name, :last_name, with: /\A[а-яА-Я]+\z/, message: "Может содержать только русские буквы"

    #Если не пустое отчество
    validates_format_of :middle_name, with: /\A[а-яА-Я]*\z/, allow_blank: true, message: "Может содержать только русские буквы"

    def full_name
     "#{last_name} #{first_name} #{middle_name}".strip
    end

    has_many :doc_pat_relationships, dependent: :delete_all
    has_many :patients, through: :doc_pat_relationships



end
