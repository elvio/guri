defmodule Guri.Adapter.Behaviour do
  @callback start_link(pid) :: {:ok, pid} | {:error, any}
  @callback send_message(pid, String.t) :: :ok
end
