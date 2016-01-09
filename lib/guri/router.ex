defmodule Guri.Router do
  @spec route_to(String.t) :: {:ok, atom} | {:error, :not_found}
  def route_to(command) do
    Application.get_env(:guri, :handlers)[command]
    |> extract_module()
  end

  defp extract_module(nil) do
    {:error, :not_found}
  end
  defp extract_module({:supervised, module}) when is_atom(module) do
    {:ok, module}
  end
  defp extract_module(module) when is_atom(module) do
    {:ok, module}
  end
end
