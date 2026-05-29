defmodule BusWhereApiWeb.Router do
  use BusWhereApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BusWhereApiWeb do
    pipe_through :api
  end
end
