defmodule MlemTest do
  use ExUnit.Case
  doctest Mlem

  test "greets the world" do
    assert Mlem.hello() == :world
  end
end
