import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :unm_class_scheduler, UnmClassScheduler.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "unm_class_scheduler_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :unm_class_scheduler, UnmClassSchedulerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "k88KGx5PAMPpymb1UXIWsrrp1g5PZtLHgARem/StJJwER9QMcrk7ET50ICSdSM1T",
  server: false

# In test we don't send emails.
config :unm_class_scheduler, UnmClassScheduler.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
