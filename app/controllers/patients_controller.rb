class PatientsController < ApplicationController
  require 'httparty'
  before_action :set_patient, only: [:show, :edit, :update, :destroy, :bmr_history, :calculate_bmr]

  def index
    default_limit = 5
    @limit = params[:limit].presence&.to_i || default_limit
    @offset = params[:offset].to_i || 0

    # Получаем параметры фильтрации
    permitted_params = params.permit(:search_last_name, :search_first_name, :search_middle_name, :search_gender, :min_age, :max_age)

    # Преобразуем параметры в хэш и проверяем наличие активных параметров
    filtered_params = permitted_params.to_h
    if params[:commit] == 'Искать' && filtered_params.any?(&:present?)
      session[:search_params] = filtered_params
    end

    # Основная логика
    if session[:search_params].present?
      scope = Patient.all
      scope = apply_filters(scope)
    else
      scope = Patient.order(id: :asc)
    end

    # Пагинация
    @patients = scope.limit(@limit).offset(@offset)

    # Общеконтекстные данные
    @total_count = scope.count
    @next_offset = @offset + @limit
    @prev_offset = [@offset - @limit, 0].max
  end


  def show
  end

  def destroy
   
    @patient.destroy
    redirect_to patients_path
  end
  
  def edit
     
  end

  def update
    
    # Шаг 1: Проверка уникальности пациента
    existing_patient = Patient.find_by(first_name: patient_params[:first_name],
                                       last_name: patient_params[:last_name],
                                       middle_name: patient_params[:middle_name],
                                       date_of_birth: patient_params[:date_of_birth])

    if existing_patient && existing_patient.id != @patient.id
      flash[:alert] = "Такой пациент уже существует."
      @patient = Patient.new(patient_params) # Создаём объект пациента для рендеринга формы
      render :edit and return
    end

    # Шаг 2: Проверка врачей
    selected_doctor_ids = params.dig(:patient, :doctor_ids)&.reject(&:blank?)&.map(&:to_i) || []
    invalid_doctors = selected_doctor_ids.reject { |id| Doctor.exists?(id: id) }

    if invalid_doctors.any?
      flash[:alert] = "Некоторые врачи не найдены в базе данных."
      @patient = Patient.new(patient_params) # Создаём объект пациента для рендеринга формы
      render :edit and return
    end

    # Шаг 3: Обновление пациента
    if @patient.update(patient_params.except(:doctor_ids))
      # Шаг 4: Обновление связей с врачами
      @patient.doctor_ids = selected_doctor_ids
      flash[:notice] = "Пациент успешно обновлён."
      redirect_to patient_path(@patient)
    else
      @patient = Patient.new(patient_params) # Создаём объект пациента для рендеринга формы
      render :edit
    end
  end




  def new
    @patient = Patient.new
  end

  def create
    # Проверка уникальности пациента
    existing_patient = Patient.exists?(first_name: patient_params[:first_name],
                                      last_name: patient_params[:last_name],
                                      middle_name: patient_params[:middle_name],
                                      date_of_birth: patient_params[:date_of_birth])

    if existing_patient
      flash[:alert] = "Такой пациент уже существует."
      @patient = Patient.new(patient_params)
      render :new and return
    end

    selected_doctor_ids = []
    if params[:patient][:doctor_ids].present?
      selected_doctor_ids = params[:patient][:doctor_ids].reject(&:blank?).map(&:to_i)
    end
    invalid_doctors = selected_doctor_ids.reject { |id| Doctor.exists?(id: id) }

    if invalid_doctors.any?
      flash[:alert] = "Некоторые врачи не найдены в базе данных."
      @patient = Patient.new(patient_params)
      render :new and return
    end

    @patient = Patient.new(patient_params.except(:doctor_ids))

    if @patient.save
      # Создание таблицы отношений
      @patient.doctor_ids = selected_doctor_ids
      flash[:notice] = "Пациент успешно создан."
      redirect_to patient_path(@patient)
    else
      render :new
    end
  end


  def calculate_bmr
    begin

      # Получение формулы
      formula = params[:formula]

      # Проверка корректности
      unless valid_formulas.include?(formula)
        render json: { error: 'Invalid formula specified.' }, status: :bad_request
        return
      end

      # Расчёт BMR
      bmr = calculate_bmr_by_formula(@patient, formula)

      # Создание записи о расчёте
      result_entry = ResultBmr.create!(
        patient: @patient,
        formula_used: formula,
        result_value: bmr,
        calculate_at: Time.zone.now
      )

      render json: {
        message: 'BMR calculation successful.',
        result_id: result_entry.id,
        calculated_bmr: bmr
      }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      # Если пациент не найден
      render json: { error: e.message }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      # Если запись не прошла валидацию
      render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
    rescue StandardError => e
      # Общее исключение, регистрируем ошибку
      logger.error "Error calculating BMR: #{e.message}\nBacktrace:\n#{e.backtrace.join("\n")}"
      render json: { error: 'Internal server error occurred while processing the request.' }, status: :internal_server_error
    end
  end

  


    def bmr_history
      begin
        # Определяем лимит записей на странице (по умолчанию 5)
        default_limit = 5
        @limit = params[:limit].presence&.to_i || default_limit
        @offset = params[:offset].to_i || 0

        # Общий счётчик записей (всех записей результата BMR пациента)
        @total_count = @patient.result_bmrs.count

        # Данные для пагинации
        @history_entries = @patient.result_bmrs.order(calculate_at: :desc).limit(@limit).offset(@offset)

        # Расчет смещений для навигации
        @next_offset = @offset + @limit
        @prev_offset = @offset - @limit

        # Флаги доступности кнопок навигации
        @has_next_page = @next_offset < @total_count
        @has_prev_page = @prev_offset >= 0

        respond_to do |format|
          format.json { render json: @history_entries.as_json(include: :patient), status: :ok }
          format.html { render 'history' }
        end
      rescue ActiveRecord::RecordNotFound => e
        render json: { error: e.message }, status: :not_found
      end
    end


  def bmi_calculate
    patient = Patient.find(params[:id])

    # Проверяем наличие обязательных данных
    return render json: { error: "Вес и рост не указаны." }, status: :bad_request if patient.weight.nil? || patient.height.nil?

    # Логируем данные пациента
    logger.info("Пациент: #{patient.attributes.inspect}")

    # Конвертация роста из сантиметров в метры
    height_in_meters = patient.height / 100.0

    # Формируем URL для запроса к API
    api_url = "https://bmicalculatorapi.vercel.app/api/bmi/#{patient.weight}/#{height_in_meters}"

    # Выполняем GET-запрос с помощью HTTParty
    response = HTTParty.get(api_url)

    # Логируем запрос и ответ для диагностики
    logger.info("API REQUEST TO #{api_url}")
    logger.info("RESPONSE CODE: #{response.code}")
    logger.info("RESPONSE BODY: #{response.body}")

    # Проверяем успешность запроса
    if response.code == 200
      result = JSON.parse(response.body)
      render json: { bmi: result['bmi'], category: result['Category'] }, status: :ok
    else
      logger.error("Ошибка при обращении к API: Код #{response.code}, Сообщение: #{response.body}")
      render json: { error: "Ошибка при обращении к API." }, status: :internal_server_error
    end
  rescue StandardError => e
    logger.error("Ошибка: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end





  


  private

  def calculate_age(birthday)
    now = Time.now.utc.to_date
    age = now.year - birthday.year
    age -= 1 if now < birthday.change(year: now.year)
    age
  end
  
  def valid_formulas
    ['mifflin_santGeora', 'harris_benedict']
  end

  # Метод для расчёта BMR в зависимости от формулы
  def calculate_bmr_by_formula(patient, formula)
    case formula
    when 'mifflin_santGeora'
      mifflin_sanjeor_calculation(patient)
    when 'harris_benedict'
      harris_benedict_calculation(patient)
    end
  end

  # Расчёт Миффлина-Сан-Жеора
  def mifflin_sanjeor_calculation(patient)
    weight_kg = patient.weight
    height_cm = patient.height
    age_years = calculate_age(patient.date_of_birth)

    if patient.gender == 'male'
      10 * weight_kg + 6.25 * height_cm - 5 * age_years + 5
    else
      10 * weight_kg + 6.25 * height_cm - 5 * age_years - 161
    end
  end

  # Расчёт Харриса-Бенедикта
  def harris_benedict_calculation(patient)
    weight_kg = patient.weight
    height_cm = patient.height
    age_years = calculate_age(patient.date_of_birth)

    if patient.gender == 'male'
      66.47 + (13.75 * weight_kg) + (5 * height_cm) - (6.74 * age_years)
    else
      655.1 + (9.6 * weight_kg) + (1.85 * height_cm) - (4.68 * age_years)
    end
  end





  def set_patient
    @patient = Patient.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(:first_name, :last_name, :middle_name, :date_of_birth, :height, :weight, :gender, doctor_ids: [])
  end

  # Функция для проверки фильтров
  def apply_filters(scope)
    # По ФИО
    scope = scope.where(last_name: params[:search_last_name]) if params[:search_last_name].present?
    scope = scope.where(first_name: params[:search_first_name]) if params[:search_first_name].present?
    scope = scope.where(middle_name: params[:search_middle_name]) if params[:search_middle_name].present?

    # По полу
    scope = scope.where(gender: params[:search_gender]) if params[:search_gender].present?

    # По возрасту
    today = Date.today
    age_filter = lambda do |age|
      adjusted_age = today.month >= today.month && today.day >= today.day ? age : age + 1
      threshold_date = today.prev_year(adjusted_age)
    end

    if params[:min_age].present? && params[:max_age].present?
      min_age = params[:min_age].to_i
      max_age = params[:max_age].to_i
      scope = scope.where('(date_of_birth <= ?) AND (date_of_birth >= ?)', age_filter.call(min_age), age_filter.call(max_age))
    elsif params[:min_age].present?
      min_age = params[:min_age].to_i
      scope = scope.where('date_of_birth <= ?', age_filter.call(min_age))
    elsif params[:max_age].present?
      max_age = params[:max_age].to_i
      scope = scope.where('date_of_birth >= ?', age_filter.call(max_age))
    end

    return scope
  end




end
