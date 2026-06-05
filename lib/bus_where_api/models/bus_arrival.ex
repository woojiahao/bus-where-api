defmodule BusWhereApi.Models.BusArrival do
  use BusWhereApi.Models.ModelBase

  defmodule Bus do
    use BusWhereApi.Models.ModelBase

    @derive {Jason.Encoder, []}
    defstruct [
      :origin_code,
      :destination_code,
      :estimated_arrival,
      :monitored,
      :latitude,
      :longitude,
      :visit_number,
      :load,
      :feature,
      :type
    ]

    @type t :: %__MODULE__{
            origin_code: integer(),
            destination_code: integer(),
            estimated_arrival: DateTime.t(),
            monitored: :schedule | :bus_location,
            latitude: float(),
            longitude: float(),
            visit_number: integer(),
            load: :seats_available | :standing_available | :limited_standing,
            feature: :wab | nil,
            type: :single_deck | :double_deck | :bendy
          }

    @impl true
    @spec from_body(map()) :: %__MODULE__{}
    def from_body(body) do
      defaults = %{
        "OriginCode" => "0",
        "DestinationCode" => "0",
        "EstimatedArrival" => "2017-04-29T07:20:24+08:00",
        "Monitored" => 0,
        "Latitude" => "0.0",
        "Longitude" => "0.0",
        "VisitNumber" => "0",
        "Load" => "SEA",
        "Feature" => nil,
        "Type" => "SD"
      }

      filled_body = Map.merge(defaults, body)

      %__MODULE__{
        origin_code: filled_body["OriginCode"] |> String.to_integer(),
        destination_code: filled_body["DestinationCode"] |> String.to_integer(),
        estimated_arrival: filled_body["EstimatedArrival"] |> DateTime.from_iso8601(),
        monitored:
          case filled_body["Monitored"] do
            0 -> :schedule
            1 -> :bus_location
          end,
        latitude: filled_body["Latitude"] |> String.to_float(),
        longitude: filled_body["Longitude"] |> String.to_float(),
        visit_number: filled_body["VisitNumber"] |> String.to_integer(),
        load:
          case filled_body["Load"] do
            "SEA" -> :seats_available
            "SDA" -> :standing_available
            "LSD" -> :limited_standing
          end,
        feature:
          case filled_body["Feature"] do
            "WAB" -> :wab
            _ -> nil
          end,
        type:
          case filled_body["Type"] do
            "SD" -> :single_deck
            "DD" -> :double_deck
            "BD" -> :bendy
          end
      }
    end
  end

  @derive {Jason.Encoder, []}
  defstruct [:service_no, :operator, :next_bus_1, :next_bus_2, :next_bus_3]

  @type t :: %__MODULE__{
          service_no: String.t(),
          operator:
            :sbs_transit | :smrt_corporation | :tower_transit_singapore | :go_ahead_singapore,
          next_bus_1: Bus.t() | nil,
          next_bus_2: Bus.t() | nil,
          next_bus_3: Bus.t() | nil
        }

  @impl true
  @spec from_body(map()) :: %__MODULE__{}
  def from_body(body) do
    defaults = %{
      "ServiceNo" => "",
      "Operator" => 0,
      "NextBus" => %Bus{},
      "NextBus2" => %Bus{},
      "NextBus3" => %Bus{}
    }

    filled_body = Map.merge(defaults, body)

    %__MODULE__{
      service_no: filled_body["ServiceNo"] |> String.to_integer(),
      operator:
        case filled_body["Operator"] do
          "SBST" -> :sbs_transit
          "SMRT" -> :smrt_corporation
          "TTS" -> :tower_transit_singapore
          "GAS" -> :go_ahead_singapore
        end,
      next_bus_1:
        case filled_body["NextBus"] do
          %Bus{} -> nil
          bus -> Bus.from_body(bus)
        end,
      next_bus_2:
        case filled_body["NextBus2"] do
          %Bus{} -> nil
          bus -> Bus.from_body(bus)
        end,
      next_bus_3:
        case filled_body["NextBus3"] do
          %Bus{} -> nil
          bus -> Bus.from_body(bus)
        end
    }
  end
end
