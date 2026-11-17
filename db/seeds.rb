# Idempotent: safe to run `bin/rails db:seed` more than once.
{
  "Learn Ruby on Rails" => :todo,
  "Learn Turbo Streams" => :doing,
  "Build Todo App" => :done
}.each do |title, status|
  Task.find_or_create_by!(title: title) { |task| task.status = status }
end
