class TasksController < ApplicationController
  before_action :set_task, only: %i[edit update destroy]

  def index
    @tasks = Task.ordered
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path, notice: "Task was added." }
        format.turbo_stream
      else
        format.html do
          @tasks = Task.ordered
          render :index, status: :unprocessable_content
        end
        format.turbo_stream { render status: :unprocessable_content }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @task.update(update_params)
        format.html { redirect_to tasks_path, notice: "Task was updated." }
        format.turbo_stream
      elsif @task.errors.include?(:title)
        format.html { render :edit, status: :unprocessable_content }
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(@task, partial: "tasks/edit_form", locals: { task: @task }),
                 status: :unprocessable_content
        end
      else
        alert = @task.errors.full_messages.to_sentence
        @task.restore_attributes

        format.html { redirect_to tasks_path, alert: alert, status: :see_other }
        format.turbo_stream { render status: :unprocessable_content }
      end
    end
  end

  def destroy
    @task.destroy!

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: "Task was deleted.", status: :see_other }
      format.turbo_stream
    end
  end

  private

  def task_params
    params.expect(task: [ :title ])
  end

  def set_task
    @task = Task.find(params.expect(:id))
  end

  def update_params
    params.expect(task: [ :title, :status ])
  end
end
