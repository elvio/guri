defmodule Guri.Bot do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{adapter_pid: nil, dispatcher_pid: nil}}
  end

  def adapter_is_ready(pid) do
    GenServer.cast(__MODULE__, {:adapter_is_ready, pid})
  end

  def dispatcher_is_ready(pid) do
    GenServer.cast(__MODULE__, {:dispatcher_is_ready, pid})
  end

  def adapter_pid do
    GenServer.call(__MODULE__, :adapter_pid)
  end

  def dispatcher_pid do
    GenServer.call(__MODULE__, :dispatcher_pid)
  end

  @spec send_message(String.t) :: :ok
  def send_message(message) do
    GenServer.call(__MODULE__, {:send_message, message})
  end

  @spec handle_command(Command.t) :: :ok
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
    Application.get_env(:guri, :adapter).send_message(state.adapter_pid, message)
    {:reply, :ok, state}
  end
  def handle_call({:handle_command, command}, _from, state) do
    Application.get_env(:guri, :dispatcher).dispatch(state.dispatcher_pid, command)
    {:reply, :ok, state}
  end

  def handle_cast({:adapter_is_ready, pid}, state) do
    {:noreply, %{state | adapter_pid: pid}}
  end
  def handle_cast({:dispatcher_is_ready, pid}, state) do
    {:noreply, %{state | dispatcher_pid: pid}}
  end
end
