defmodule BusWhereApiWeb.Router do
  use BusWhereApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BusWhereApiWeb do
    pipe_through :api

    get "/bus_arrival", LtaController, :bus_arrival
    get "/bus_services", LtaController, :bus_services
    get "/bus_routes", LtaController, :bus_routes
  end
end
