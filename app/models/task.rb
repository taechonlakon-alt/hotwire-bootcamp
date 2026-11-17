class Task < ApplicationRecord
  NEXT_STATUS = { "todo" => "doing", "doing" => "done", "done" => "todo" }.freeze

  enum :status, { todo: 0, doing: 1, done: 2 }, default: :todo, validate: true

  validates :title, presence: true

  scope :ordered, -> { order(:created_at, :id) }
  scope :not_done, -> { where.not(status: :done) }

  def next_status
    NEXT_STATUS.fetch(status)
  end
end
