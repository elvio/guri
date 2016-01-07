defmodule Guri.BotTest do
  use ExUnit.Case, async: true
  alias Guri.{Bot, Command}

  defmodule Adapter do
    use GenServer
    @behaviour Guri.Adapter.Behaviour

    def start_link(bot), do: GenServer.start_link(__MODULE__, [bot], name: __MODULE__)
    def init([_bot]), do: {:ok, []}
    def messages_sent, do: GenServer.call(__MODULE__, :messages_sent)
    def send_message(message), do: GenServer.cast(__MODULE__, {:send_message, message})
    def handle_call(:messages_sent, _from, state), do: {:reply, state, state}
    def handle_cast({:send_message, message}, state), do: {:noreply, [message | state]}
  end

  defmodule Dispatcher do
    use GenServer
    @behaviour Guri.Dispatcher.Behaviour

    def start_link(bot), do: GenServer.start_link(__MODULE__, [bot], name: __MODULE__)
    def init([_bot]), do: {:ok, []}
    def handled_commands, do: GenServer.call(__MODULE__, :handled_commands)
    def dispatch(command), do: GenServer.cast(__MODULE__, {:dispatch, command})
    def handle_call(:handled_commands, _from, state), do: {:reply, state, state}
    def handle_cast({:dispatch, command}, state), do: {:noreply, [command | state]}
  end

  setup do
    {:ok, _} = Adapter.start_link(Bot)
    {:ok, _} = Dispatcher.start_link(Bot)
    {:ok, _} = Bot.start_link(Adapter, Dispatcher)
    :ok
  end

  test "sends message to adapter" do
    Bot.send_message("message 1")
    assert Adapter.messages_sent() == ["message 1"]
  end

  test "dispatches command" do
    command = %Command{name: "test"}
    Bot.handle_command(command)
    assert Dispatcher.handled_commands() == [command]
  end
end
