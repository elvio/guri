defmodule Guri.Adapters.Slack.CommandTest do
  use ExUnit.Case, async: true
  alias Guri.Adapters.Slack.Command

  test "parses single commands" do
    message = %{
      "text" => "<@id>: deploy"
    }

    parsed = Command.parse(message)
    assert parsed.name == "deploy"
    assert parsed.args == []
  end

  test "parses commands with arguments" do
    message = %{
      "text" => "<@id>: deploy `project` to `production`"
    }

    parsed = Command.parse(message)
    assert parsed.name == "deploy"
    assert parsed.args == ["project", "to", "production"]
  end

  test "parses invalid commands" do
    message = %{
      "text" => ""
    }

    parsed = Command.parse(message)
    assert parsed.name == nil
    assert parsed.args == []
  end
end
