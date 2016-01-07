defmodule Guri.Command do
  alias Guri.Command

  @type t :: %Command{name: String.t,
                      args: [String.t]}

  defstruct name: nil,
            args: []
end
