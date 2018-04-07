defmodule LoggexTest do
  use ExUnit.Case
  doctest Loggex

  test "greets the world" do
    assert Loggex.hello() == :world
  end
end
