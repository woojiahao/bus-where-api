defmodule BusWhereApi.Services.LtaService do
  alias BusWhereApi.Models

  @cache_ttl_minutes 60

  @spec bus_arrival(integer(), String.t() | nil) ::
          list(Models.BusArrival.t()) | {:error, BusWhereApi.Error.t()}
  def bus_arrival(bus_stop_code, service_no \\ nil) do
    case cache_fetch(
           "v3/BusArrival",
           %{"BusStopCode" => bus_stop_code, "ServiceNo" => service_no},
           20
         ) do
      {:error, err} -> {:error, err}
      %{"Services" => arrivals} -> Enum.map(arrivals, &Models.BusArrival.from_body/1)
      _ -> {:error, BusWhereApi.Error.not_found("Arrival information could not be found")}
    end
  end

  @spec bus_services(String.t() | nil) ::
          list(Models.BusService.t()) | {:error, BusWhereApi.Error.t()}
  def bus_services(service_no \\ nil) do
    case cache_fetch_all("BusServices", "value", %{"ServiceNo" => service_no}, 60) do
      {:error, err} -> {:error, err}
      services -> Enum.map(services, &Models.BusService.from_body/1)
    end
  end

  @spec bus_routes() :: list(BusWhereApi.Models.BusStop) | {:error, BusWhereApi.Error.t()}
  def bus_routes do
    case cache_fetch_all("BusRoutes") do
      {:error, err} -> {:error, err}
      routes -> Enum.map(routes, &BusWhereApi.Models.BusStop.from_body/1)
    end
  end

  @spec cache_fetch_all(String.t(), String.t(), map(), integer()) ::
          list(map()) | {:error, BusWhereApi.Error.t()}
  defp cache_fetch_all(
         path,
         list_key \\ "value",
         path_parameters \\ %{},
         cache_duration_seconds \\ @cache_ttl_minutes * 60
       ) do
    cache_key = {path, path_parameters}

    case Cachex.exists?(:lta_cache, cache_key) do
      {:ok, true} ->
        {:ok, models} = Cachex.get(:lta_cache, cache_key)
        models

      {:ok, false} ->
        case BusWhereApi.Clients.LtaClient.get_all(path, path_parameters, list_key) do
          {:error, err} ->
            {:error, BusWhereApi.Error.external_failure(err)}

          models ->
            Cachex.put(
              :lta_cache,
              cache_key,
              models,
              ttl: :timer.seconds(cache_duration_seconds)
            )

            models
        end
    end
  end

  @spec cache_fetch(String.t(), map(), integer()) :: map() | {:error, BusWhereApi.Error.t()}
  defp cache_fetch(
         path,
         path_parameters \\ %{},
         cache_duration_seconds \\ @cache_ttl_minutes * 60
       ) do
    cache_key = {path, path_parameters}

    case Cachex.exists?(:lta_cache, cache_key) do
      {:ok, true} ->
        {:ok, models} = Cachex.get(:lta_cache, cache_key)
        models

      {:ok, false} ->
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
              ttl: :timer.seconds(cache_duration_seconds)
            )

            body
        end
    end
  end
end
