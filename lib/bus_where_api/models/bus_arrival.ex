defmodule BusWhereApi.Models.BusArrival do
  use BusWhereApi.Models.ModelBase

  defmodule Bus do
    use BusWhereApi.Models.ModelBase

    field(:origin_code, :integer, "OriginCode", default: "0")
    field(:destination_code, :integer, "DestinationCode", default: "0")

    field(:estimated_arrival, :datetime, "EstimatedArrival",
      default: "2017-04-29T07:20:24+08:00",
      offset_s: 8 * 60 * 60
    )

    enum(:monitored, %{0 => :schedule, 1 => :bus_location}, "Monitored", default: 0)
    field(:latitude, :float, "Latitude", default: "0.0")
    field(:longitude, :float, "Longitude", default: "0.0")
    field(:visit_number, :integer, "VisitNumber", default: "0")

    enum(
      :load,
      %{"SEA" => :seats_available, "SDA" => :standing_available, "LSD" => :limited_standing},
      "Load",
      default: "SEA"
    )

    enum(
      :feature,
      %{"WAB" => :wab, nil => nil},
      "Feature",
      default: nil
    )

    enum(
      :type,
      %{
        "SD" => :single_deck,
        "DD" => :double_deck,
        "BD" => :bendy
      },
      "Feature",
      default: "SD"
    )
  end

  field(:service_no, :string, "ServiceNo", default: "")

  enum(
    :operator,
    %{
      "SBST" => :sbs_transit,
      "SMRT" => :smrt_corporation,
      "TTS" => :tower_transit_singapore,
      "GAS" => :go_ahead_singapore
    },
    "Operator",
    default: "SBST"
  )

  field(:next_bus_1, {:struct, Bus}, "NextBus")
  field(:next_bus_2, {:struct, Bus}, "NextBus2")
  field(:next_bus_3, {:struct, Bus}, "NextBus3")
end
