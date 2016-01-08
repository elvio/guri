defmodule Guri.Dispatcher do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{handlers: %{}}}
  end

  def register_command_handler(command_name, handler) do
    GenServer.cast(__MODULE__, {:register_command_handler, command_name, handler})
  end

  def handler_for(command_name) do
    GenServer.call(__MODULE__, {:handler_for, command_name})
  end

  def dispatch(command) do
    GenServer.call(__MODULE__, {:dispatch, command})
  end

  def handle_call({:handler_for, command_name}, _from, state) do
    {:reply, state.handlers[command_name], state}
  end
  def handle_call({:dispatch, %{name: command_name} = command}, _from, state) do
    handler = state.handlers[command_name]
    handler.handle_command(command)
    {:reply, :ok, state}
  end

  def handle_cast({:register_command_handler, command_name, handler}, state) do
    {:noreply, put_in(state.handlers[command_name], handler)}
  end

  # def dispatch()
end
