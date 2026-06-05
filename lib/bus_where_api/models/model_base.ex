defmodule BusWhereApi.Models.ModelBase do
  @callback from_body(map()) :: struct()

  defmacro __using__(_opts) do
    quote do
      @behaviour BusWhereApi.Models.ModelBase

      @derive {Jason.Encoder, []}
    end
  end
end
