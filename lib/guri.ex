defmodule Guri do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    adapter = Application.get_env(:guri, :adapter)
    handlers = supervised_handlers()
    |> Enum.map(fn(m) -> worker(m, []) end)

    children = [
      worker(Guri.Bot, [adapter]),
      worker(adapter, [])
    ] ++ handlers

    opts = [strategy: :one_for_one, name: Guri.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp supervised_handlers() do
    Application.get_env(:guri, :handlers)
    |> Enum.filter(fn(handler) -> is_supervised(handler) end)
    |> Enum.map(fn(handler) -> module_name(handler) end)
  end

  def is_supervised({_key, {:supervised, _module}}), do: true
  def is_supervised(_), do: false

  def module_name({_key, {:supervised, module}}), do: module
end
