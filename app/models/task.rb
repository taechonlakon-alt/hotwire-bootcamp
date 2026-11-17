class Task < ApplicationRecord
  NEXT_STATUS = { "todo" => "doing", "doing" => "done", "done" => "todo" }.freeze

  enum :status, { todo: 0, doing: 1, done: 2 }, default: :todo, validate: true

  validates :title, presence: true

  scope :ordered, -> { order(:created_at, :id) }
  scope :not_done, -> { where.not(status: :done) }

  after_create_commit -> { broadcast_append_later_to "tasks", target: "tasks" }
  after_update_commit -> { broadcast_replace_later_to "tasks" }
  after_destroy_commit -> { broadcast_remove_to "tasks" }
  after_commit :broadcast_stats_later

  def next_status
    NEXT_STATUS.fetch(status)
  end

  private

  def broadcast_stats_later
    Turbo::StreamsChannel.broadcast_replace_later_to "tasks", target: "task_stats", partial: "tasks/stats"
  end
end
