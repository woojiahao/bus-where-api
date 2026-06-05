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
          integer(),
          list(map())
        ) :: list(map()) | {:error, term()}
  def get_all(path, skip \\ 0, acc \\ []) do
    case get("#{path}?$skip=#{skip}") do
      {:ok, %{status_code: 200, body: %{"value" => []}}} ->
        acc

      {:ok, %{status_code: 200, body: %{"value" => value}}} ->
        get_all(path, skip + 500, Enum.concat(acc, value))

      {:ok, %{status_code: _}} ->
        {:error, :bad_request}

      {:error, err} ->
        {:error, err}
    end
  end
end
