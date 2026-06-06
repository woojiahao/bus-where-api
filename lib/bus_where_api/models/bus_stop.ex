defmodule BusWhereApi.Models.BusStop do
  use BusWhereApi.Models.ModelBase

  field(:bus_stop_code, :integer, "BusStopCode", default: 0)
  field(:road_name, :string, "RoadName", default: "")
  field(:description, :string, "Description", default: "")
  field(:latitude, :float, "Latitude", default: 0.0)
  field(:longitude, :float, "Longitude", default: 0.0)
end
