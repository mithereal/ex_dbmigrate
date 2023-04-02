defmodule ExDbmigrateTest do
  use ExUnit.Case
  doctest ExDbmigrate

  test "greets the world" do
    assert ExDbmigrate.hello() == :world
  end
end
