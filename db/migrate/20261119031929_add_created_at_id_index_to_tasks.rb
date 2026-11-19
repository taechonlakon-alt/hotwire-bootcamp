class AddCreatedAtIdIndexToTasks < ActiveRecord::Migration[8.1]
  def change
    # Backs the keyset pagination order (created_at DESC, id DESC) in TasksController#index.
    add_index :tasks, [ :created_at, :id ]
  end
end
