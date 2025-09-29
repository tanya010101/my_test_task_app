class DoctorsController < ApplicationController
before_action :set_doctor, only: [:show, :edit, :update, :destroy]

  def index
    default_limit = 5
    @limit = params[:limit].presence&.to_i || default_limit
    @offset = params[:offset].to_i || 0

    @doctors = Doctor.limit(@limit).offset(@offset).order(id: :asc)

    @total_count = Doctor.count

    # Вычисление смещений
    @next_offset = @offset + @limit
    @prev_offset = [@offset - @limit, 0].max

  end

  def show
  end

  def new
    @doctor = Doctor.new
  end

  def edit
  end

  def create
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      redirect_to doctor_path(@doctor), notice: 'Врач успешно добавлен!'
    else
      render :new
    end
  end

  def update
    if @doctor.update(doctor_params)
      redirect_to doctor_path(@doctor), notice: 'Данные врача обновлены.'
    else
      render :edit
    end
  end

  def destroy
    @doctor.destroy
    redirect_to doctors_path
  end


  private

  def set_doctor
    @doctor = Doctor.find(params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(:first_name, :last_name, :middle_name)
  end
  

end
