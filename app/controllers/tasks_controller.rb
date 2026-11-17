class TasksController < ApplicationController
  def index
    @tasks = Task.ordered
    @task = Task.new
  end
end
