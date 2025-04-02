defmodule IdbTest do
  use ExUnit.Case
  doctest Idb

  test "greets the world" do
    assert Idb.hello() == :world
  end
end
