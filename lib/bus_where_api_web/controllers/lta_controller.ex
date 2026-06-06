defmodule BusWhereApiWeb.LtaController do
  use BusWhereApiWeb, :controller

  action_fallback BusWhereApiWeb.Controllers.FallbackController

  def bus_arrival(conn, %{"bus_stop_code" => bus_stop_code, "service_no" => service_no}) do
    case BusWhereApi.Services.LtaService.bus_arrival(bus_stop_code, service_no) do
      {:error, err} -> {:error, err}
      arrival -> json(conn, arrival)
    end
  end

  def bus_arrival(conn, %{"bus_stop_code" => bus_stop_code}) do
    case BusWhereApi.Services.LtaService.bus_arrival(bus_stop_code) do
      {:error, err} -> {:error, err}
      arrival -> json(conn, arrival)
    end
  end

  def bus_arrival(_, _) do
    {:error, BusWhereApi.Error.bad_request("Missing bus_stop_code parameter")}
  end

  def bus_services(conn, params) do
    case BusWhereApi.Services.LtaService.bus_services(Map.get(params, "service_no")) do
      {:error, err} -> {:error, err}
      services -> json(conn, services)
    end
  end

  def bus_routes(conn, _params) do
    case BusWhereApi.Services.LtaService.bus_routes() do
      {:error, err} -> {:error, err}
      routes -> json(conn, routes)
    end
  end

  def bus_stops(conn, params) do
    case BusWhereApi.Services.LtaService.bus_stops(Map.get(params, "bus_stop_code")) do
      {:error, err} -> {:error, err}
      routes -> json(conn, routes)
    end
  end
end
