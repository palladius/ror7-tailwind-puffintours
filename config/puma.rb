# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `worker_timeout` threshold that Puma will use to wait before
# terminating a worker in development environments.
#
worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Keep-alive timeout > Render's 60s load balancer timeout to prevent 502 Bad Gateway
persistent_timeout 65
first_data_timeout 30

# Run any pending migrations after Puma has bound to $PORT so Render's port scanner
# sees the open port immediately without booting a second Ruby process.
after_booted do
  if ENV["RAILS_ENV"] == "production" && ENV.fetch("AUTO_MIGRATE_ON_BOOT", "true") == "true"
    Thread.new do
      begin
        ActiveRecord::Base.connection_pool.with_connection do
          if ActiveRecord::Base.connection.migration_context.needs_migration?
            Rails.logger.info("🐧 Running pending database migrations after Puma boot...")
            ActiveRecord::Tasks::DatabaseTasks.migrate
          end
        end
      rescue StandardError => e
        Rails.logger.warn("🐧 Post-boot migration check skipped: #{e.class} - #{e.message}")
      end
    end
  end
end

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
# preload_app!

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
