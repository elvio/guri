defmodule Guri.Adapters.Slack.CommandParserTest do
  use ExUnit.Case, async: true
  alias Guri.Adapters.Slack.CommandParser

  test "parses single commands" do
    message = %{
      "text" => "<@id>: deploy"
    }

    parsed = CommandParser.run(message)
    assert parsed.name == "deploy"
    assert parsed.args == []
  end

  test "parses commands with arguments" do
    message = %{
      "text" => "<@id>: deploy `project` to `production`"
    }

    parsed = CommandParser.run(message)
    assert parsed.name == "deploy"
    assert parsed.args == ["project", "to", "production"]
  end

  test "parses invalid commands" do
    message = %{
      "text" => ""
    }

    parsed = CommandParser.run(message)
    assert parsed.name == nil
    assert parsed.args == []
  end
end
