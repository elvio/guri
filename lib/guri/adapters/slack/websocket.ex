defmodule Guri.Adapters.Slack.WebSocket do
  @behaviour :websocket_client
  require Logger

  alias Guri.Adapters.Slack.{API, Command, Message}

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

  def websocket_handle({_type, raw_message}, _conn_state, state) do
    case Message.parse(raw_message, state.bot_id, state.channel_id) do
      {:ok, message} -> parse_command_and_send_to_handler(message)
      _ -> :ok
    end

    {:ok, state}
  end

  def websocket_info({:send_message, message}, _conn_state, state) do
    reply = Message.reply(state.channel_id, message)
    {:reply, {:text, reply}, state}
  end

  def onconnect(_wsreq, state) do
    {:ok, state}
  end

  def ondisconnect({:remote, :closed}, state) do
    {:ok, state}
  end

  defp parse_command_and_send_to_handler(message) do
    command = Command.parse(message)
    route = Guri.Router.route_to(command.name)
    send_to_handler(command, route)
  end

  defp send_to_handler(command, {:ok, handler}) do
    Logger.info("Sending '#{command.name}' to '#{inspect(handler)}'")
    handler.handle_command(command)
  end
  defp send_to_handler(command, {:error, :not_found}) do
    Logger.error("Could not find handler for '#{command.name}' command")
  end
end
