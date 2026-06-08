defmodule BusWhereApi.Services.LtaService do
  alias BusWhereApi.Models

  # Given that the data is unlikely to keep changing, we can hold the cache for longer 
  # to avoid long roundtrips for the enduser
  @cache_ttl_minutes 24 * 60

  @spec bus_arrival(integer(), String.t() | nil) ::
          list(Models.BusArrival.t()) | {:error, BusWhereApi.Error.t()}
  def bus_arrival(bus_stop_code, service_no \\ nil) do
    case cache_fetch(
           "v3/BusArrival",
           %{"BusStopCode" => bus_stop_code, "ServiceNo" => service_no},
           15
         ) do
      {:error, err} ->
        {:error, err}

      %{"Services" => []} ->
        {:error, BusWhereApi.Error.not_found("Arrival information could not be found")}

      %{"Services" => arrivals} ->
        Enum.map(arrivals, &Models.BusArrival.from_body/1)

      _ ->
        {:error, BusWhereApi.Error.not_found("Arrival information could not be found")}
    end
  end

  @spec bus_services(String.t() | nil) ::
          list(Models.BusService.t()) | {:error, BusWhereApi.Error.t()}
  def bus_services(service_no \\ nil) do
    case cache_fetch_all("BusServices", %{"ServiceNo" => service_no}) do
      {:error, err} -> {:error, err}
      services -> Enum.map(services, &Models.BusService.from_body/1)
    end
  end

  @spec bus_routes() :: list(Models.BusRoute.t()) | {:error, BusWhereApi.Error.t()}
  def bus_routes do
    case cache_fetch_all("BusRoutes", %{}) do
      {:error, err} -> {:error, err}
      routes -> Enum.map(routes, &Models.BusRoute.from_body/1)
    end
  end

  @spec bus_stops(integer() | nil) :: list(Models.BusStop.t()) | {:error, BusWhereApi.Error.t()}
  def bus_stops(bus_stop_code \\ nil) do
    case cache_fetch_all("BusStops", %{"BusStopCode" => bus_stop_code}) do
      {:error, err} -> {:error, err}
      bus_stops -> Enum.map(bus_stops, &Models.BusStop.from_body/1)
    end
  end

  @spec cache_fetch_all(String.t(), map(), integer(), String.t()) ::
          list(map()) | {:error, BusWhereApi.Error.t()}
  defp cache_fetch_all(
         path,
         path_parameters \\ %{},
         cache_duration_seconds \\ @cache_ttl_minutes * 60,
         list_key \\ "value"
       ) do
    cache_key = {path, path_parameters}

    fetch_and_cache_api = fn ->
      case BusWhereApi.Clients.LtaClient.get_all(path, path_parameters, list_key) do
        {:error, err} ->
          {:error, BusWhereApi.Error.external_failure(err)}

        models ->
          Cachex.put(
            :lta_cache,
            cache_key,
            models,
            expire: :timer.seconds(cache_duration_seconds)
          )

          models
      end
    end

    case Cachex.get(:lta_cache, cache_key) do
      {:ok, nil} -> fetch_and_cache_api.()
      {:ok, models} -> models
      _ -> fetch_and_cache_api.()
    end
  end

  @spec cache_fetch(String.t(), map(), integer()) :: map() | {:error, BusWhereApi.Error.t()}
  defp cache_fetch(
         path,
         path_parameters \\ %{},
         cache_duration_seconds \\ @cache_ttl_minutes * 60
       ) do
    cache_key = {path, path_parameters}

    fetch_and_cache_api = fn ->
      full_path =
        BusWhereApi.Clients.LtaClient.create_path(path, path_parameters)

      case BusWhereApi.Clients.LtaClient.get(full_path) do
        {:error, err} ->
          {:error, BusWhereApi.Error.external_failure(err)}

        {:ok, %{body: body}} ->
          Cachex.put(
            :lta_cache,
            cache_key,
            body,
            expire: :timer.seconds(cache_duration_seconds)
          )

          body
      end
    end

    case Cachex.get(:lta_cache, cache_key) do
      {:ok, nil} -> fetch_and_cache_api.()
      {:ok, cached_body} -> cached_body
      _ -> fetch_and_cache_api.()
    end
  end
end
