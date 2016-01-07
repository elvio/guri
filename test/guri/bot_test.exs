defmodule Guri.BotTest do
  use ExUnit.Case, async: true
  alias Guri.{Bot, Command}

  defmodule Adapter do
    use GenServer
    @behaviour Guri.Adapter.Behaviour

    def start_link(_pid), do: GenServer.start_link(__MODULE__, [])
    def init([]), do: {:ok, []}
    def messages_sent(pid), do: GenServer.call(pid, :messages_sent)
    def send_message(pid, message), do: GenServer.cast(pid, {:send_message, pid, message})
    def handle_call(:messages_sent, _from, state), do: {:reply, state, state}
    def handle_cast({:send_message, pid, message}, state), do: {:noreply, [{pid, message} | state]}
  end

  defmodule Dispatcher do
    use GenServer
    @behaviour Guri.Dispatcher.Behaviour

    def start_link(_pid), do: GenServer.start_link(__MODULE__, [])
    def init([]), do: {:ok, []}
    def handled_commands(pid), do: GenServer.call(pid, :handled_commands)
    def dispatch(pid, command), do: GenServer.cast(pid, {:dispatch, command})
    def handle_cast({:dispatch, command}, state), do: {:noreply, [command | state]}
    def handle_call(:handled_commands, _from, state), do: {:reply, state, state}
  end

  Application.put_env(:guri, :adapter, Adapter)
  Application.put_env(:guri, :dispatcher, Dispatcher)

  setup do
    {:ok, _bot_pid} = Bot.start_link()
    :ok
  end

  test "register adapter pid" do
    Bot.adapter_is_ready("pid")
    assert Bot.adapter_pid() == "pid"
  end

  test "register dispatcher pid" do
    Bot.dispatcher_is_ready("pid")
    assert Bot.dispatcher_pid() == "pid"
  end

  test "sends message to adapter" do
    {:ok, adapter_pid} = Adapter.start_link(nil)
    Bot.adapter_is_ready(adapter_pid)
    Bot.send_message("message 1")

    assert Adapter.messages_sent(adapter_pid) == [{adapter_pid, "message 1"}]
  end

  test "dispatches command" do
    {:ok, dispatcher_pid} = Dispatcher.start_link(nil)
    Bot.dispatcher_is_ready(dispatcher_pid)
    command = %Command{name: "test"}
    Bot.handle_command(command)

    assert Dispatcher.handled_commands(dispatcher_pid) == [command]
  end
end
