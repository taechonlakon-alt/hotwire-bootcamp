namespace :db do
  desc "db:prepare that also works when cache/queue/cable share the primary database (e.g. Render free Postgres)"
  task prepare_shared: :load_config do
    # Plain db:prepare loads a schema only into a database with no schema_migrations table.
    # When cache/queue/cable point at the primary database, the primary schema creates that
    # table first, so the Solid schemas are never loaded. Load each missing schema ourselves,
    # identified by a table it creates, then let db:prepare run any pending migrations.
    marker_tables = {
      "primary" => "schema_migrations",
      "cache" => "solid_cache_entries",
      "queue" => "solid_queue_jobs",
      "cable" => "solid_cable_messages"
    }
    fresh_database = false

    marker_tables.each do |name, table|
      db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: name)
      next unless db_config

      ActiveRecord::Base.establish_connection(db_config)
      begin
        next if ActiveRecord::Base.connection.table_exists?(table)
      rescue ActiveRecord::NoDatabaseError
        ActiveRecord::Tasks::DatabaseTasks.create(db_config)
        retry
      end

      fresh_database = true if name == "primary"
      puts "Loading #{name} schema"
      ActiveRecord::Tasks::DatabaseTasks.load_schema(db_config)
    end

    ActiveRecord::Base.establish_connection
    Rake::Task["db:prepare"].invoke
    # Seed after every schema exists, so seeds that enqueue jobs (Turbo broadcasts) succeed.
    Rake::Task["db:seed"].invoke if fresh_database
  end
end
