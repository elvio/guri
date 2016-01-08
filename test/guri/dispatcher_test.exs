defmodule Guri.DispatcherTest do
  use ExUnit.Case, async: true
  alias Guri.{Command, Dispatcher}

  defmodule Handler do
    def start_link, do: Agent.start_link(fn -> [] end, name: __MODULE__)
    def handle_command(command), do: Agent.update(__MODULE__, fn(state) -> [command | state] end)
    def handled, do: Agent.get(__MODULE__, fn(state) -> state end)
  end

  test "registers command handler" do
    {:ok, _} = Dispatcher.start_link()
    Dispatcher.register_command_handler("test", Handler)
    assert Dispatcher.handler_for("test") == Handler
  end

  test "dispatches a command to a handler" do
    {:ok, _} = Dispatcher.start_link()
    {:ok, _} = Handler.start_link()
    Dispatcher.register_command_handler("test", Handler)
    command = %Command{name: "test"}
    Dispatcher.dispatch(command)
    assert Handler.handled() == [command]
  end
end
