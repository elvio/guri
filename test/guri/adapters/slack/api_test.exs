defmodule Guri.Adapters.Slack.APITest do
  use ExUnit.Case, async: true
  alias Guri.Adapters.Slack.API

  test "returns the websocket url as char_list" do
    url = "ws://test"
    response = %{"url" => url}
    assert API.websocket_url(response) == String.to_char_list(url)
  end

  test "returns the user id by name" do
    user_id = "UJOHNID"
    user_name = "john"

    response = %{
      "users" => [
        %{"id" => user_id, "name" => user_name},
        %{"id" => "other_id", "name" => "other_name"}
      ]
    }

    assert API.user_id_by_name(response, user_name) == user_id
  end

  test "returns the channel id by name" do
    channel_id = "CGENERALID"
    channel_name = "general"

    response = %{
      "channels" => [
        %{"id" => channel_id, "name" => channel_name},
        %{"id" => "other_id", "name" => "other_name"}
      ]
    }

    assert API.channel_id_by_name(response, channel_name) == channel_id
  end
end
