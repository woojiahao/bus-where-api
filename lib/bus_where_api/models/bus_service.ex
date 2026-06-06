defmodule BusWhereApi.Models.BusService do
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

  field(:direction, :integer, "Direction", default: 1)
  # TODO: scope this as an enum instead
  field(:category, :string, "Category", default: "EXPRESS")
  field(:origin_code, :integer, "OriginCode", default: "0")
  field(:destination_code, :integer, "DestinationCode", default: "0")

  field(
    :am_peak_freq,
    :string,
    "AM_Peak_Freq",
    default: "-",
    parser: &Helpers.parse_freq_string/1
  )

  field(
    :am_offpeak_freq,
    :string,
    "AM_Offpeak_Freq",
    default: "-",
    parser: &Helpers.parse_freq_string/1
  )

  field(
    :pm_peak_freq,
    :string,
    "PM_Peak_Freq",
    default: "-",
    parser: &Helpers.parse_freq_string/1
  )

  field(
    :pm_offpeak_freq,
    :string,
    "PM_Offpeak_Freq",
    default: "-",
    parser: &Helpers.parse_freq_string/1
  )

  field(:loop_desc, :string, "LoopDesc", default: "")
end
