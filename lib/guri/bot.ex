defmodule Guri.Bot do
  use GenServer

  def start_link(adapter, dispatcher) do
    GenServer.start_link(__MODULE__, [adapter, dispatcher], name: __MODULE__)
  end

  def init([adapter, dispatcher]) do
    {:ok, %{adapter: adapter, dispatcher: dispatcher}}
  end

  @spec send_message(String.t) :: :ok
  def send_message(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  @spec handle_command(Guri.Command.t) :: :ok
  def handle_command(command) do
    GenServer.call(__MODULE__, {:handle_command, command})
  end

  def handle_call(:adapter_pid, _from, state) do
    {:reply, state.adapter_pid, state}
  end
  def handle_call(:dispatcher_pid, _from, state) do
    {:reply, state.dispatcher_pid, state}
  end
  def handle_call({:send_message, message}, _from, state) do
    state.adapter.send_message(message)
    {:reply, :ok, state}
  end
  def handle_call({:handle_command, command}, _from, state) do
    state.dispatcher.dispatch(command)
    {:reply, :ok, state}
  end

  def handle_cast({:adapter_is_ready, pid}, state) do
    {:noreply, %{state | adapter_pid: pid}}
  end
  def handle_cast({:dispatcher_is_ready, pid}, state) do
    {:noreply, %{state | dispatcher_pid: pid}}
  end
end
