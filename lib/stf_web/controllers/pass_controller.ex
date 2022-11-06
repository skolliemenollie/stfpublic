defmodule StfWeb.PassController do
  use StfWeb, :controller
  alias Stf.Tasks

  require Logger
  @timeout 15000

  def generate(conn, params) do
    %Plug.Conn{req_headers: req_headers} = conn
    token = req_headers
      |> Enum.into([], fn {k, v} -> if k == "authorization", do: v end)
      |> Enum.filter(& !is_nil(&1))
      |> List.first()
    with {:ok, _} <- generate_trail_pass(params) do
      if token == "#{Application.get_env(:stf, :token)}" do
        conn
        |> send_resp(200, "ok")
      else
        conn
        |> send_resp(401, "nope")
      end
    end
  end

  defp generate_trail_pass(params) do
    create_image = fn -> Tasks.generate_pass(params) end
    task = Task.Supervisor.async(Stf.TaskSupervisor, create_image)
    case Task.yield(task, @timeout) || Task.shutdown(task) do
      {:ok, result} ->
        case result do
          {:ok, body} ->
            Logger.info "Successfully created the pass image for #{params["msisdn"]}"
            file = File.read!("#{Application.get_env(:stf, :location)}/#{params["msisdn"]}.png")
              |> Base.encode64()
              |> send_image_to_whatsapp(params)
            {:ok, body}
          {:error, reason} ->
            Logger.error reason
            {:error, "An error has occurred"}
        end
      {:exit, reason} ->
        Logger.error reason
        {:error, reason}
      nil ->
        message = "Failed to create the pass image for #{params["msisdn"]}"
        Logger.error message
        {:error, message}
    end
  end

  defp send_image_to_whatsapp(file, params) do
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", Application.get_env(:stf, :clickatell_token)}
    ]
    url = "https://platform.clickatell.com/v1/message"
    body = %{
      "messages": [
        %{
          "channel": "whatsapp",
          "to": params["msisdn"],
          "content": file,
          "media": %{
            "contentType": "image/png",
            "caption": "Hi #{params["name"]}, here is your trail pass. Proudly delivered by Clickatell."
          }
        }
      ]
    }
    payload = body |> Jason.encode!()
    response = HTTPoison.post url, payload, headers
    case response do
      {:ok, response} ->
        Logger.info "Successfully sent the pass for #{params["msisdn"]}"
        with :ok <= File.rm("#{Application.get_env(:stf, :location)}/#{params["msisdn"]}.png") do
          Logger.info "Successfully deleted the pass for #{params["msisdn"]}"
          :ok
        end
      {:error, response} ->
        Logger.error response.reason
        :error
    end
  end
end
