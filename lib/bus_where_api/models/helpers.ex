defmodule BusWhereApi.Models.Helpers do
  def parse_freq_string(freq_string),
    do:
      freq_string
      |> String.split("-")
      |> Enum.reject(&(&1 == ""))
      |> then(fn
        [] ->
          %{}

        arr ->
          Enum.map(arr, &String.to_integer/1)
          |> then(fn
            [start_value] -> %{start_value: start_value}
            [start_value, end_value] -> %{start_value: start_value, end_value: end_value}
          end)
      end)
end
