defmodule Guri do
  use Application

  @bot_name Guri.Bot

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Guri.Bot, []),
      worker(Application.get_env(:guri, :adapter), [@bot_name]),
      worker(Application.get_env(:guri, :dispatcher), [@bot_name]),
    ]

    opts = [strategy: :one_for_one, name: Guri.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
