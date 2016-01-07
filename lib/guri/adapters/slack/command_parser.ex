defmodule Guri.Adapters.Slack.CommandParser do
  @pattern ~r/<@(?<to>.*)>: (?<command>\S+)\s{0,1}(?<args>.*)/

  alias Guri.Command

  @spec run(map) :: Command.t
  def run(%{"text" => text} = message) do
    regex = Regex.named_captures(@pattern, text)

    {message, regex || %{}, %Command{}}
    |> extract_command_and_args()
    |> return_command()
  end

  @spec extract_command_and_args({map, map, Command.t}) :: {map, map, Command.t}
  defp extract_command_and_args({original, regex, command}) do
    args = parse_and_clean_args(regex["args"])
    new_command = %Command{command | name: regex["command"], args: args}
    {original, regex, new_command}
  end

  @spec return_command({map, map, Command.t}) :: Command.t
  defp return_command({_original, _regex, command}) do
    command
  end

  @spec parse_and_clean_args(String.t) :: [String.t]
  defp parse_and_clean_args(args) do
    args
    |> to_string
    |> String.replace("`", "")
    |> String.split(" ")
    |> Enum.filter(fn(a) -> String.length(a) > 0 end)
  end
end
