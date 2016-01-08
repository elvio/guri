defmodule Guri do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    adapter = Application.get_env(:guri, :adapter)

    children = [
      worker(Guri.Bot, [adapter]),
      worker(Guri.Dispatcher, []),
      worker(adapter, [])
    ]
    
    opts = [strategy: :one_for_one, name: Guri.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
