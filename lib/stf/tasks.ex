defmodule Stf.Tasks do
  @moduledoc """
  The Tasks context.
  """
  require Logger

  def generate_pass(data) do
    blob = data["line_items"] |> List.first |> Map.get("meta_data")
    reduced = Enum.into(blob, [], fn k ->
      case Map.get(k, "display_key") do
        "Trail Pass" -> k
        "Riding Date" -> k
        "Riders Details" -> k
        _ -> nil
      end
    end)
    |> Enum.filter(& !is_nil(&1))
    trail = reduced |> Enum.fetch!(0) |> Map.get("display_value")
    date = reduced |> Enum.fetch!(1) |> Map.get("display_value")
    name = reduced |> Enum.fetch!(2) |> Map.get("display_value") |> String.split |> Enum.fetch!(2)
    msisdn = reduced |> Enum.fetch!(2) |> Map.get("display_value") |> String.split |> Enum.fetch!(3) |> String.replace_leading("0", "27")
    formatted = %{trail: trail, name: name, date: date, msisdn: msisdn}
    location = Application.get_env(:stf, :location)
    template = "#{location}/template.png"
    System.cmd("convert", setup_pass(template, location, formatted))
    with {:ok, _} <- File.read("#{location}/#{formatted.msisdn}.png") do
      {:ok, formatted}
    end
  end

  defp setup_pass(template, location, data) do
    [
      "#{template}",
      #name
      "-font",
      "#{location}/Calibri.otf",
      "-pointsize",
      "22",
      "-fill",
      "black",
      "-gravity",
      "center",
      "-annotate",
      "-10-110",
      "#{data.name}",
      #date
      "-font",
      "#{location}/Calibri.otf",
      "-pointsize",
      "22",
      "-fill",
      "black",
      "-gravity",
      "center",
      "-annotate",
      "-10-24",
      "#{data.date}",
      #trail
      "-font",
      "#{location}/Calibri.otf",
      "-pointsize",
      "14",
      "-fill",
      "black",
      "-gravity",
      "center",
      "-annotate",
      "-0+110",
      "#{data.trail}",
      "#{location}/#{data.msisdn}.png"
    ]
  end

  def send_message() do

  end
end
