defmodule AheTrackerPeteWeb.UserView do
  use AheTrackerPeteWeb, :view
  alias AheTrackerPeteWeb.UserView
  alias AheTrackerPeteWeb.CountView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end

  def render("user_with_counts.json", %{user: user, counts: counts}) do
    %{
      user_id: user.id,
      counts: render_many(counts, CountView, "count.json")
    }
  end
end
