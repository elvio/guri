defmodule Guri.Adapters.Slack.API do
  def start_link do
    Agent.start_link(fn -> request("rtm.start") end, name: __MODULE__)
  end

  def start_link(response) do
    Agent.start_link(fn -> response end, name: __MODULE__)
  end

  def get_info do
    %{websocket_url: websocket_url(),
      channel_id: channel_id(),
      bot_id: bot_id()}
  end

  defp websocket_url do
    Agent.get(__MODULE__, fn(response) ->
      response["url"] |> String.to_char_list
    end)
  end

  defp channel_id, do: get_id_by_name("channels", config(:channel_name))
  defp bot_id, do: get_id_by_name("users", config(:bot_name))

  defp get_id_by_name(source, name) do
    Agent.get(__MODULE__, fn(response) ->
      [item] = Enum.filter(response[source], fn(c) -> c["name"] == name end)
      item["id"]
    end)
  end

  @spec request(String.t) :: map
  defp request(method) do
    method
    |> url_for()
    |> get()
    |> parse_body()
  end

  @spec url_for(String.t) :: String.t
  defp url_for(method) do
    config(:url) <> "/" <> method <> "?token=" <> config(:token)
  end

  defp get(url) do
    Application.get_env(:guri, :http_client_library).get!(url)
  end

  @spec parse_body(any) :: map
  defp parse_body(response) do
    Application.get_env(:guri, :json_library).decode!(response.body)
  end

  @spec config(atom) :: String.t
  defp config(key) do
    Application.get_env(:guri, :slack)[key]
  end
end
