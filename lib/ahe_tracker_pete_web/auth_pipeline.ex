defmodule AheTrackerPete.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :ahe_tracker_pete,
    module: AheTrackerPete.Guardian,
    error_handler: AheTrackerPete.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
