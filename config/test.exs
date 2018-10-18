use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ahe_tracker_pete, AheTrackerPeteWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :ahe_tracker_pete, AheTrackerPete.Repo,
  username: "postgres",
  password: "postgres",
  database: "ahe_tracker_pete_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
