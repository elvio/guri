defmodule Guri.Adapters.Slack do
  @behaviour :websocket_client
  require Logger

  alias Guri.Adapters.Slack.{API, CommandParser}

  @spec start_link() :: {:ok, pid} | {:error, any}
  def start_link do
    response = API.rtm_start()
    %{websocket_url: websocket_url, channel_id: channel_id, bot_id: bot_id} = API.get_info(response)
    {:ok, pid} = :websocket_client.start_link(websocket_url, __MODULE__, {bot_id, channel_id})
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  @spec init({String.t, String.t}) :: {:once, any}
  def init({bot_id, channel_id}) do
    Logger.info("Connected to Slack")
    {:once, %{bot_id: bot_id, channel_id: channel_id}}
  end

  @spec send_message(String.t) :: :ok
  def send_message(message) do
    Logger.info("Sending message to Slack channel: #{message}")
    send(__MODULE__, {:send_message, message})
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
    |> Guri.Dispatcher.dispatch()
  end
  defp handle_message(message) do
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
end
