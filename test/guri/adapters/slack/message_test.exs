defmodule Guri.Adapters.Slack.MessageTest do
  use ExUnit.Case, async: true
  alias Guri.Adapters.Slack.Message

  test "non-command messages are ignored" do
    message = ~s|{"type":"hello"}|
    assert Message.parse(message, "bot", "channel") == :ignore
  end

  test "messages sent to a different channel are ignored" do
    message = ~s|{"type":"message", "channel":"other", "text":"<@bot>: deploy"}|
    assert Message.parse(message, "bot", "channel") == :ignore
  end

  test "messages sent to a different bot user are ignored" do
    message = ~s|{"type":"message", "channel":"channel", "text":"<@user>: deploy"}|
    assert Message.parse(message, "bot", "channel") == :ignore
  end

  test "recognizes valid messages" do
    text = "<@bot>: deploy"
    message = ~s|{"type":"message", "channel":"channel", "text":"#{text}"}|
    json_message = %{"text" => text}
    assert Message.parse(message, "bot", "channel") == {:ok, json_message}
  end

  test "creates a encoded reply" do
    reply = Application.get_env(:guri, :json_library).decode!(Message.reply("ch", "testing"))
    assert reply == %{"type" => "message",
                     "channel" => "ch",
                     "text" => "<!channel>: testing"}
  end
end
