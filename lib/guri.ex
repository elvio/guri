defmodule Guri do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    adapter = Application.get_env(:guri, :adapter)
    handler_modules = Application.get_env(:guri, :handlers)

    handlers = Enum.map(handler_modules, fn(handler) ->
      worker(handler, [])
    end)

    children = [
      worker(Guri.Bot, [adapter]),
      worker(Guri.Dispatcher, []),
      worker(adapter, [])
    ] ++ handlers

    opts = [strategy: :one_for_one, name: Guri.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
