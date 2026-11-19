# Idempotent: safe to run `bin/rails db:seed` more than once.
{
  "Learn Ruby on Rails" => :todo,
  "Learn Turbo Streams" => :doing,
  "Build Todo App" => :done
}.each do |title, status|
  Task.find_or_create_by!(title: title) { |task| task.status = status }
end

# Bulk tasks for performance testing. insert_all skips model callbacks,
# so this does not enqueue 10,000 Turbo broadcast jobs.
BULK_TASK_COUNT = 10_000
BULK_TASK_PREFIX = "Seed task"

existing = Task.where("title LIKE ?", "#{BULK_TASK_PREFIX} %").count
if existing < BULK_TASK_COUNT
  statuses = Task.statuses.values
  now = Time.current
  rows = ((existing + 1)..BULK_TASK_COUNT).map do |i|
    { title: "#{BULK_TASK_PREFIX} #{i}", status: statuses.sample, created_at: now, updated_at: now }
  end
  rows.each_slice(1_000) { |batch| Task.insert_all(batch) }
end
