defmodule Guri.Handler do
  @callback handle_command(Guri.Command.t) :: :ok | :error

  defmacro __using__(_) do
    quote do
      def send_message(message) do
        Module.concat(Application.get_env(:guri, :adapter), :Bot).send_message(message)
      end
    end
  end
end
