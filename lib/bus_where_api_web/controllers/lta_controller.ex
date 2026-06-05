defmodule BusWhereApiWeb.LtaController do
  use BusWhereApiWeb, :controller

  action_fallback BusWhereApiWeb.Controllers.FallbackController

  def arrival(conn, %{"bus_stop_code" => bus_stop_code, "service_no" => service_no}) do
    case BusWhereApi.Services.LtaService.arrival(bus_stop_code, service_no) do
      {:error, err} -> {:error, err}
      arrival -> json(conn, arrival)
    end
  end

  def arrival(conn, %{"bus_stop_code" => bus_stop_code}) do
    case BusWhereApi.Services.LtaService.arrival(bus_stop_code) do
      {:error, err} -> {:error, err}
      arrival -> json(conn, arrival)
    end
  end

  def arrival(_, _) do
    {:error, BusWhereApi.Error.bad_request("Missing bus_stop_code parameter")}
  end

  def bus_routes(conn, _params) do
    bus_routes = BusWhereApi.Services.LtaService.bus_routes()
    json(conn, bus_routes)
  end
end
