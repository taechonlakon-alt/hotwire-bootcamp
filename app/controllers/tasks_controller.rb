class TasksController < ApplicationController
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

  private

  def task_params
    params.expect(task: [ :title ])
  end
end
