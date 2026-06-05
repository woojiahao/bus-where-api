defmodule BusWhereApiWeb.Router do
  use BusWhereApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BusWhereApiWeb do
    pipe_through :api

    get "/arrival", LtaController, :arrival
    get "/bus_routes", LtaController, :bus_routes
  end
end
