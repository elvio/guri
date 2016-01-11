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
  [{:guri, "~> 0.2.1"}]
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
#
# MyApp.Deploy is a supervised handler
# MyApp.Stat is a non-supervised handler
#
config :guri, :handlers, %{"deploy" => {:supervised, MyApp.Deploy},
                           "stat"   => MyApp.Stat}
```

With the described configuration, every time someone sends a `deploy` command, `MyApp.Deploy` will receive the command information. The same happens to the `stat` command and `MyApp.Stat` module.

### Command Handlers

Command handlers are responsible for processing the commands published in a chat room. Using the previous example, `MyApp.Deploy` and `MyApp.Stat` are command handlers. Each command handler is able to handle a single command. A handler can be of two types:

#### Supervised

Supervised handlers need to keep state. You will probably use an `Agent` or `GenServer` in order to keep the state. These handlers will be started as part of the application supervision three. When defining the handler in the `config.exs` file, it uses a tuple like `{:supervised, MODULE_NAME}`.

Example of `MyApp.Deploy` handler:

```elixir
defmodule MyApp.Deploy do
  use Guri.Handler

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def handle_command(%{name: "deploy", args: []}) do
    send_message("Deploying all projects to production")
  end
  def handle_command(%{name: "deploy", args: [project]}) do
    send_message("Deploying `#{project}` to production")
  end
  def handle_command(%{name: "deploy", args: [project, "to", env]}) do
    send_message("Deploying `#{project}` to `#{env}`")
  end
  def handle_command(_) do
    send_message("Sorry, I couldn't understand what you want to deploy")
  end
end
```

#### Non-Supervised

Non-Supervised handlers don't need to keep state. They are just simple modules.

Example of `MyApp.Stat` handler:

```elixir
defmodule MyApp.Stat do
  use Guri.Handler

  def handle_command(%{name: "stat", args: []}) do
    stats = StatService.get_and_process_stats()
    send_message(stats)
  end
  def handle_command(_) do
    send_message("Sorry, I couldn't understand the stat you are looking for")
  end
end
```

### Run Test

```
mix test
```
