defmodule BusWhereApi.Clients.LtaClient do
  use HTTPoison.Base

  @endpoint "https://datamall2.mytransport.sg"

  @spec process_request_url(binary) :: binary
  def process_request_url(url) do
    @endpoint
    |> URI.merge("ltaodataservice/" <> url)
    |> URI.to_string()
  end

  @spec process_request_headers(term) :: [{binary, term}]
  def process_request_headers(_headers) do
    account_key = Application.fetch_env!(:bus_where_api, :lta_account_key)

    [
      {:AccountKey, account_key},
      {:accept, "application/json"}
    ]
  end

  @spec process_response_body(binary()) :: term()
  def process_response_body(body) do
    Jason.decode!(body)
  end

  @spec get_all(
          String.t(),
          map(),
          String.t(),
          integer(),
          list(map())
        ) :: list(map()) | {:error, term()}
  def get_all(path, path_parameters \\ %{}, list_key \\ "value", skip \\ 0, acc \\ []) do
    path_parameters = Map.put(path_parameters, "$skip", skip)

    full_path = create_path(path, path_parameters)

    case get(full_path) do
      {:ok, %{status_code: 200, body: %{^list_key => []}}} ->
        acc

      {:ok, %{status_code: 200, body: %{^list_key => value}}} ->
        get_all(path, path_parameters, list_key, skip + 500, Enum.concat(acc, value))

      {:ok, %{status_code: _}} ->
        {:error, :bad_request}

      {:error, err} ->
        {:error, err}
    end
  end

  @spec create_path(String.t(), map()) :: String.t()
  def create_path(path, path_parameters),
    do: create_path_inner(path, Enum.reject(path_parameters, fn {_, v} -> is_nil(v) end))

  defp create_path_inner(path, path_parameters) when map_size(path_parameters) == 0, do: path

  defp create_path_inner(path, path_parameters),
    do:
      path <>
        "?" <>
        (path_parameters
         |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
         |> Enum.join("&"))
end
