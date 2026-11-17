module TasksHelper
  def task_counts
    { total: Task.count, todo: Task.not_done.count, done: Task.done.count }
  end
end
