defmodule Guri.Mixfile do
  use Mix.Project

  def project do
    [app: :guri,
     version: "0.0.1",
     elixir: "~> 1.2",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     aliases: [test: "test --no-start"]]
  end

  def application do
    [applications: [:logger, :crypto, :ssl, :httpoison],
     mod: {Guri, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.8.0"},
      {:websocket_client, "~> 1.1.0"},
      {:poison, "~> 1.5.0"}]
  end

  defp description do
    """
    Automate using chat bots
    """
  end

  defp package do
    [maintainers: ["Elvio Vicosa"],
     links: %{"Github" => "https://github.com/elvio/guri"}]
  end
end
