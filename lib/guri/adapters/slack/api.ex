defmodule Guri.Adapters.Slack.API do
  @spec rtm_start() :: map
  def rtm_start() do
    request("rtm.start")
  end

  @spec websocket_url(map) :: char_list
  def websocket_url(response) do
    response["url"]
    |> String.to_char_list()
  end

  @spec user_id_by_name(map, String.t) :: String.t
  def user_id_by_name(response, name) do
    exctract(response["users"], "name", name, "id")
  end

  @spec channel_id_by_name(map, String.t) :: String.t
  def channel_id_by_name(response, name) do
    exctract(response["channels"], "name", name, "id")
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

  @spec exctract(map, String.t, String.t, String.t) :: String.t
  defp exctract(map, key, value, field) do
    [item] = Enum.filter(map, fn(i) -> i[key] == value end)
    item[field]
  end

  @spec config(atom) :: String.t
  defp config(key) do
    Application.get_env(:guri, :slack)[key]
  end
end
