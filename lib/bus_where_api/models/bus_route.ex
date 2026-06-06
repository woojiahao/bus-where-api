defmodule BusWhereApi.Models.BusRoute do
  use BusWhereApi.Models.ModelBase

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

  field(:direction, :integer, "Direction", default: 0)
  field(:stop_sequence, :integer, "StopSequence", default: 0)
  field(:bus_stop_code, :integer, "BusStopCode", default: 0)
  field(:distance, :float, "Distance", default: 0.0)
  field(:weekday_first_bus, :integer, "WD_FirstBus", default: "2025")
  field(:weekday_last_bus, :integer, "WD_LastBus", default: "2025")
  field(:saturday_first_bus, :integer, "SAT_FirstBus", default: "2025")
  field(:saturday_last_bus, :integer, "SAT_LastBus", default: "2025")
  field(:sunday_first_bus, :integer, "SUN_FirstBus", default: "2025")
  field(:sunday_last_bus, :integer, "SUN_LastBus", default: "2025")
end
