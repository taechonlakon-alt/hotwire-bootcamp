class TasksController < ApplicationController
  TASKS_PER_PAGE = 10
  # The page cursor would otherwise round created_at to milliseconds. Postgres stores microseconds,
  # so rows sharing the cursor's millisecond (e.g. bulk-seeded tasks) would be skipped.
  KEEP_MICROSECONDS = ->(attributes) { attributes[:created_at] = attributes[:created_at].utc.strftime("%F %T.%6N") }

  before_action :set_task, only: %i[edit update destroy]

  def index
    paginate_tasks

    # The lazy "load more" frame asks for the next page; answer with just that page.
    if turbo_frame_request?
      render partial: "tasks/page", locals: { tasks: @tasks, pagy: @pagy }
    else
      @task = Task.new
    end
  end

  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to tasks_path, notice: "Task was added." }
        format.turbo_stream
      else
        format.html do
          paginate_tasks
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

  # Keyset pagination: no COUNT query, and pages don't shift when tasks are added or removed.
  def paginate_tasks
    @pagy, @tasks = pagy(:keyset, Task.ordered, limit: TASKS_PER_PAGE, pre_serialize: KEEP_MICROSECONDS)
  end

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
