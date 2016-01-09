defmodule Guri.RouterTest do
  use ExUnit.Case, async: true

  defmodule Deploy do
  end

  defmodule Stats do
  end

  @handlers %{"deploy" => {:supervised, Deploy},
              "stats"  => Stats}

  Application.put_env(:guri, :handlers, @handlers)

  test "routes to a supervised handler" do
    assert Guri.Router.route_to("deploy") == {:ok, Deploy}
  end

  test "routes to a non-supervised handler" do
    assert Guri.Router.route_to("stats") == {:ok, Stats}
  end

  test "returns :not_found error" do
    assert Guri.Router.route_to("invalid") == {:error, :not_found}
  end
end
