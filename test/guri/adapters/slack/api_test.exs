defmodule Guri.Adapters.Slack.APITest do
  use ExUnit.Case, async: true
  alias Guri.Adapters.Slack.API

  @bot_name "test_bot"
  @channel_name "test_channel"
  @websocket_url "ws://socket.guri.test"
  Application.put_env(:guri, :slack, bot_name: @bot_name, channel_name: @channel_name)

  test "gets api information" do
    users = [%{"id" => 1, "name" => @bot_name}]
    channels = [%{"id" => 2, "name" => @channel_name}]
    response = %{"url" => @websocket_url, "users" => users, "channels" => channels}

    API.start_link(response)
    assert API.get_info() == %{bot_id: 1, channel_id: 2, websocket_url: String.to_char_list(@websocket_url)}
  end
end
