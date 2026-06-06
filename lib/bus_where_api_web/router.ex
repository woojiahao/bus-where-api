defmodule BusWhereApiWeb.Router do
  use BusWhereApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BusWhereApiWeb do
    pipe_through :api

    scope "/bus" do
      get "/arrival", LtaController, :bus_arrival
      get "/services", LtaController, :bus_services
      get "/routes", LtaController, :bus_routes
      get "/stops", LtaController, :bus_stops
    end
  end
end
