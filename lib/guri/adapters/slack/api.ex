defmodule Guri.Adapters.Slack.API do
  def rtm_start() do
    request("rtm.start")
  end

  def get_info(response) do
    %{websocket_url: websocket_url(response),
      channel_id: channel_id(response),
      bot_id: bot_id(response)}
  end

  defp websocket_url(response) do
    response["url"] |> String.to_char_list
  end

  defp channel_id(response), do: get_id_by_name(response, "channels", config(:channel_name))
  defp bot_id(response), do: get_id_by_name(response, "users", config(:bot_name))

  defp get_id_by_name(response, source, name) do
    [item] = Enum.filter(response[source], fn(c) -> c["name"] == name end)
    item["id"]
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
