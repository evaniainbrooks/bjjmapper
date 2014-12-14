class StudentsController < ApplicationController
  before_action :set_instructor
  before_action :set_student, only: [:destroy]
  before_action :set_students, only: [:index]

  decorates_assigned :students

  def index
    respond_to do |format|
      format.json { render status: :ok, json: students }
    end
  end

  def create
    @student = find_or_create_student
    @instructor.lineal_children << @student

    tracker.track('createStudent',
      instructor: @instructor.to_param,
      id: @student.to_param,
      createdNewUser: params.key?(:user)
    )

    respond_to do |format|
      format.html { redirect_to user_path(@instructor, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  def destroy
    tracker.track('deleteStudent',
      id: @student.to_param,
      instructor: @instructor.to_param
    )

    @instructor.lineal_children.delete(@student)

    respond_to do |format|
      format.html { redirect_to user_path(@instructor, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  private

  def set_students
    @students = @instructor.lineal_children
    render(status: :no_content, json: {}) and return false if @students.empty?
  end

  def find_or_create_student
    if params.key?(:user)
      User.create!(create_params)
    else
      User.find(params[:id])
    end
  end

  def create_params
    params.require(:user).permit(:name, :image, :email, :belt_rank, :stripe_rank, :birth_day, :birth_month, :birth_year, :lineal_parent, :birth_place, :description)
  end

  def set_instructor
    id_param = params.fetch(:user_id, '')
    @instructor = User.find(id_param)
    head :not_found and return false unless @instructor.present?
  end

  def set_student
    @student = @instructor.lineal_children.find(params[:id])
    head :not_found and return false unless @student.present?
  end
end
