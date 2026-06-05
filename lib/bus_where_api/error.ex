defmodule BusWhereApi.Error do
  @enforce_keys [:code]
  defstruct [:code, :message, :details]

  @type t :: %__MODULE__{
          code: atom(),
          message: String.t() | nil,
          details: any()
        }

  def bad_request(msg \\ "bad request", details \\ nil) do
    %__MODULE__{code: :bad_request, message: msg, details: details}
  end

  def not_found(msg \\ "not found", details \\ nil) do
    %__MODULE__{code: :not_found, message: msg, details: details}
  end

  def external_failure(details \\ nil) do
    %__MODULE__{code: :external_failure, message: "external API failure", details: details}
  end
end
