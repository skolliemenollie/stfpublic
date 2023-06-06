defmodule Stf.Tasks do
  @moduledoc """
  The Tasks context.
  """
  require Logger

  def generate_pass(data) do
    list = data["_json"]
    passes = Enum.into(list, [], fn pass ->
      trail = pass["trailPark"]
      name = pass["billing"]["first_name"] <> " " <> pass["billing"]["last_name"]
      date = pass["ridingDate"]
      msisdn = pass["billing"]["phone"] |> String.replace_leading("0", "27")
      sku = pass["uniqueSKU"]
      %{trail: trail, name: name, date: date, msisdn: msisdn, sku: sku}
    end)

    location = Application.get_env(:stf, :location)
    template = "#{location}/template.png"

    generated_list = Enum.into(passes, [], fn pass ->
      System.cmd("convert", setup_pass(template, location, pass))
      with {:ok, _} <- File.read("#{location}/#{pass.sku}.png") do
        pass
      end
    end)

    {:ok, generated_list}
  end

  defp setup_pass(template, location, data) do
    [
      "#{template}",
      #sku
      "-font",
      "#{location}/Calibri.otf",
      "-pointsize",
      "22",
      "-fill",
      "black",
      "-gravity",
      "center",
      "-annotate",
      "-0-0",
      "#{data.sku}",
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
      "#{location}/#{data.sku}.png"
    ]
  end

  def send_message() do

  end
end
