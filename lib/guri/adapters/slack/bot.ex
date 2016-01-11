defmodule Guri.Adapters.Slack.Bot do
  @spec send_message(String.t) :: :ok
  def send_message(message) do
    send(Guri.Adapters.Slack.WebSocket, {:send_message, message})
  end
end
