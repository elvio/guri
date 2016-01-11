defmodule Guri.Adapters.Slack.Message do
  @spec parse(String.t, String.t, String.t) :: {:ok, map} | :ignore
  def parse(raw_message, bot_id, channel_id) do
    raw_message
    |> decode_json()
    |> _parse(bot_id, channel_id)
    |> validate_message()
  end

  @spec reply(String.t, String.t) :: String.t
  def reply(channel_id, message) do
    encode_json(%{type: :message, channel: channel_id, text: "<!channel>: " <> message})
  end

  @spec decode_json(String.t) :: map
  defp decode_json(nil) do
    %{}
  end
  defp decode_json("") do
    %{}
  end
  defp decode_json(string) do
    Application.get_env(:guri, :json_library).decode!(string)
  end

  @spec _parse(map, String.t, String.t) :: map
  defp _parse(message, bot_id, channel_id) do
    text = to_string(message["text"])
    to_bot = String.starts_with?(text, "<@#{bot_id}>: ")
    to_channel = message["channel"] == channel_id

    %{"text"  => text,
      "type"  => message["type"],
      "valid" => to_bot && to_channel}
  end

  @spec validate_message(map) :: {:ok, map} | :ignore
  def validate_message(%{"type" => "message", "valid" => true} = message) do
    {:ok, Map.take(message, ["text"])}
  end
  def validate_message(_) do
    :ignore
  end

  @spec encode_json(map) :: String.t
  defp encode_json(map) do
    Application.get_env(:guri, :json_library).encode!(map)
  end
end
