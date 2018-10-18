defmodule AheTrackerPete.Repo do
  use Ecto.Repo,
    otp_app: :ahe_tracker_pete,
    adapter: Ecto.Adapters.Postgres
end
