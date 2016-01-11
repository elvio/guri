defmodule Guri.Adapters.Slack.Message do
  @spec parse(String.t, String.t, String.t) :: {:ok, map} | :ignore
  def parse(raw_message, bot_id, channel_id) do
    raw_message
    |> decode_json()
    |> _parse(bot_id, channel_id)
    |> validate_message()
  end

  @spec reply(String.t, Strint.t) :: String.t
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

  # raw_message
  # |> decode_json()
  # |> validate_message(state.bot_id, state.channel_id)
  # |> handle_message()

  # @spec validate_message(map, String.t, String.t) :: map
  # defp validate_message(message, bot_id, channel_id) do
  #   text = to_string(message["text"])
  #   type = message["type"]
  #   sent_to_bot = String.starts_with?(text, "<@#{bot_id}>: ")
  #   sent_to_channel = message["channel"] == channel_id
  #   validate_message(message, type, sent_to_bot, sent_to_channel)
  # end
  #
  # @spec validate_message(map, String.t, boolean, boolean) :: map
  # defp validate_message(message, "message", true, true) do
  #   Map.put(message, "valid", true)
  # end
  # defp validate_message(message, _, _, _) do
  #   Map.put(message, "valid", false)
  # end

  # @spec handle_message(map) :: :ok | :ignored
  # defp handle_message(%{"valid" => true} = message) do
  #   command = message
  #   |> CommandParser.run()
  #
  #   case Guri.Router.route_to(command.name) do
  #     {:ok, handler} ->
  #       handler.handle_command(command)
  #
  #     {:error, :not_found} ->
  #       Logger.error("Could not find handler for '#{command.name}' command")
  #   end
  #
  #   :ok
  # end
  # defp handle_message(message) do
  # end

end
