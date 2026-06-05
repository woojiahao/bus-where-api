defmodule BusWhereApi.Models.BusStop do
  use BusWhereApi.Models.ModelBase

  field(:code, :integer, "BusStopCode", default: "0")
  field(:service_no, :string, "ServiceNo", default: "")
end
