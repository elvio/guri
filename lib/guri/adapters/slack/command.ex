defmodule Guri.Adapters.Slack.Command do
  @pattern ~r/<@(?<to>.*)>: (?<command>\S+)\s{0,1}(?<args>.*)/

  @spec parse(map) :: Guri.Command.t
  def parse(%{"text" => text} = message) do
    regex = Regex.named_captures(@pattern, text)

    {message, regex || %{}, %Guri.Command{}}
    |> extract_command_and_args()
    |> return_command()
  end

  @spec extract_command_and_args({map, map, Guri.Command.t}) :: {map, map, Guri.Command.t}
  defp extract_command_and_args({original, regex, command}) do
    args = parse_and_clean_args(regex["args"])
    new_command = %Guri.Command{command | name: regex["command"], args: args}
    {original, regex, new_command}
  end

  @spec return_command({map, map, Guri.Command.t}) :: Guri.Command.t
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
