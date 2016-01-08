defmodule Guri.BotTest do
  use ExUnit.Case, async: true
  alias Guri.{Bot, Command, Dispatcher}

  defmodule Adapter do
    def start_link, do: Agent.start_link(fn -> [] end, name: __MODULE__)
    def send_message(message), do: Agent.update(__MODULE__, fn(state) -> [message | state] end)
    def sent_messages, do: Agent.get(__MODULE__, fn(state) -> state end)
  end

  test "sends message to adapter" do
    {:ok, _adapter_pid} = Adapter.start_link()
    {:ok, _bot_pid} = Bot.start_link(Adapter)
    Bot.send_message("message 1")
    assert Adapter.sent_messages() == ["message 1"]
  end

  test "dispatches command" do
    {:ok, _dispatcher_pid} = Dispatcher.start_link()
    {:ok, _bot_pid} = Bot.start_link(nil)
    command = %Command{name: "test"}
    Bot.handle_command(command)
    assert Dispatcher.handled_commands() == [command]
  end
end
