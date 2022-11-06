defmodule Stf.Tasks do
  @moduledoc """
  The Tasks context.
  """
  require Logger

  def generate_pass(data) do
    location = Application.get_env(:stf, :location)
    template = "#{location}/template.png"
    System.cmd("convert", setup_pass(template, location, data))
    with {:ok, _} <- File.read("#{location}/#{data["msisdn"]}.png") do
      {:ok, "Image for #{data["msisdn"]} exists"}
    end
  end

  defp setup_pass(template, location, data) do
    [
      "#{template}",
      "-font",
      "#{location}cards/Arial.otf",
      "-pointsize",
      "28",
      "-fill",
      "white",
      "-gravity",
      "east",
      "-annotate",
      "+60-20",
      "blah",
      "#{location}/#{data["msisdn"]}.png"
    ]
  end

  def send_message() do

  end
end
