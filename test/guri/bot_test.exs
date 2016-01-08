defmodule Guri.BotTest do
  use ExUnit.Case, async: true

  defmodule Adapter do
    def start_link, do: Agent.start_link(fn -> [] end, name: __MODULE__)
    def send_message(message), do: Agent.update(__MODULE__, fn(state) -> [message | state] end)
    def sent_messages, do: Agent.get(__MODULE__, fn(state) -> state end)
  end

  test "sends message to adapter" do
    {:ok, _adapter_pid} = Adapter.start_link()
    {:ok, _bot_pid} = Guri.Bot.start_link(Adapter)
    Guri.Bot.send_message("message 1")
    assert Adapter.sent_messages() == ["message 1"]
  end
end
