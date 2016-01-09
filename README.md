Guri
========

Guri was created to automate tasks and let people know about what's happening. It is a bot system that uses chat messages as commands. You can easily write command handlers to automate anything you want. Nice things you can automate (but not limited to):

* Deploy a project to a specific environment (e.g. production, staging)
* Scale a specific environment up/down
* Enable or Disable features (feature toggle)
* Create/close a Github issue

Guri is not only limited to command handling. It can also be used to automatically post useful information to a chat room.

Usage
-----

Add Guri to your `mix.exs` dependencies:

```elixir
defp deps do
  [{:guri, "~> 0.1.0"}]
end
```

Add Guri to your `mix.exs` applications:

```elixir
def application do
  [applications: [:guri]]
end
```

And run:

```
mix deps.get
```

### Configuration

In your `config/config.exs` add the following config:
```elixir

# Bot adapter (currently only Slack is supported)
config :guri, :adapter, Guri.Adapters.Slack

# Configure your Slack bot
config :guri, :slack,
  bot_name: "BOT_NAME", # the one you created in Slack
  channel_name: "CHANNEL_NAME", # the name of the channel the bot is in
  url: "https://slack.com/api",
  token: "TOKEN" # Token from Slack (e.g.: abced-00000000-AASDADzxczxcasd)

# Command Handlers you want to use
config :guri, :handlers, [
    MyApp.Deploy,
    MyApp.Stats
]
```

### Creating a Handler

You can create as many handlers as you wish. The example bellow is using an `Agent`, but you
can use a `GenServer` or even a simple module. Your handler needs to call `Guri.Dispatcher.register_handler(__MODULE__, ["deploy"])` in order to answer to any `deploy` command. A single handler can handle different commands (e.g. `Guri.Dispatcher.register_handler(MyApp.Deploy, ["deploy", "rollback"])`).

```elixir
# Example of handler responsible for deployments

defmodule MyApp.Deploy do
  def start_link do
    {:ok, pid} = Agent.start_link(fn -> [] end, name: __MODULE__)
    Guri.Dispatcher.register_handler(__MODULE__, ["deploy"])
    {:ok, pid}
  end

  def handle_command(%{name: "deploy", args: []}) do
    Guri.Bot.send_message("Deploying all projects to production")
  end
  def handle_command(%{name: "deploy", args: [project]}) do
    Guri.Bot.send_message("Deploying `#{project}` to production")
  end
  def handle_command(%{name: "deploy", args: [project, "to", env]}) do
    Guri.Bot.send_message("Deploying `#{project}` to `#{env}`")
  end
  def handle_command(_) do
    Guri.Bot.send_message("Sorry, I couldn't understand what you want to deploy")
  end
end
```

### Run Test

```
mix test
```
