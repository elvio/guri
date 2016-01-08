defmodule Guri.Bot do
  use GenServer
  alias Guri.Dispatcher

  def start_link(adapter) do
    GenServer.start_link(__MODULE__, [adapter], name: __MODULE__)
  end

  def init([adapter]) do
    {:ok, %{adapter: adapter}}
  end

  @spec send_message(String.t) :: :ok
  def send_message(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  @spec handle_command(Guri.Command.t) :: :ok
  def handle_command(command) do
    GenServer.call(__MODULE__, {:handle_command, command})
  end

  def handle_call({:send_message, message}, _from, state) do
    state.adapter.send_message(message)
    {:reply, :ok, state}
  end
  def handle_call({:handle_command, command}, _from, state) do
    Dispatcher.dispatch(command)
    {:reply, :ok, state}
  end
end
