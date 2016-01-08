defmodule Guri.Adapters.Slack do
  @behaviour :websocket_client

  alias Guri.Bot
  alias Guri.Adapters.Slack.{API, CommandParser}

  @spec start_link() :: {:ok, pid} | {:error, any}
  def start_link() do
    {websocket_url, bot_id, channel_id} = get_api_info()
    :websocket_client.start_link(websocket_url, __MODULE__, {bot_id, channel_id}, name: __MODULE__)
  end

  @spec init({String.t, String.t}) :: {:once, any}
  def init({bot_id, channel_id}) do
    {:once, %{bot_id: bot_id, channel_id: channel_id}}
  end

  @spec send_message(pid, String.t) :: :ok
  def send_message(pid, message) do
    send(pid, {:send_message, message})
  end

  def websocket_handle({_type, raw_message}, _conn_state, state) do
    raw_message
    |> decode_json()
    |> validate_message(state.bot_id, state.channel_id)
    |> handle_message()

    {:ok, state}
  end

  def websocket_info({:send_message, message}, _conn_state, state) do
    reply = encode_json(%{type: :message, channel: state.channel_id, text: "<!channel>: " <> message})
    {:reply, {:text, reply}, state}
  end

  defp validate_message(message, bot_id, channel_id) do
    text = to_string(message["text"])
    type = message["type"]
    sent_to_bot = String.starts_with?(text, "<@#{bot_id}>: ")
    sent_to_channel = message["channel"] == channel_id
    validate_message(message, type, sent_to_bot, sent_to_channel)
  end

  defp validate_message(message, "message", true, true) do
    Map.put(message, "valid", true)
  end
  defp validate_message(message, _, _, _) do
    Map.put(message, "valid", false)
  end

  defp handle_message(%{"valid" => true} = message) do
    message
    |> CommandParser.run()
    |> Bot.handle_command()
  end
  defp handle_message(_, _) do
  end

  def onconnect(_wsreq, state) do
    {:ok, state}
  end

  def ondisconnect({:remote, :closed}, state) do
    {:ok, state}
  end

  defp decode_json(nil) do
    %{}
  end
  defp decode_json("") do
    %{}
  end
  defp decode_json(string) do
    Application.get_env(:guri, :json_library).decode!(string)
  end

  defp encode_json(map) do
    Application.get_env(:guri, :json_library).encode!(map)
  end

  @spec get_api_info :: {char_list, String.t, String.t}
  defp get_api_info do
    response = API.rtm_start()
    websocket_url = API.websocket_url(response)
    bot_id = API.user_id_by_name(response, Application.get_env(:guri, :slack)[:bot_name])
    channel_id = API.channel_id_by_name(response, Application.get_env(:guri, :slack)[:channel_name])
    {websocket_url, bot_id, channel_id}
  end
end
