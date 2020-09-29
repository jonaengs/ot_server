defmodule OTServerTest do
  use ExUnit.Case
  doctest OTServer

  test "greets the world" do
    assert OTServer.hello() == :world
  end
end
