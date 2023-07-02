defmodule ExDbmigrateTest do
  use ExUnit.Case
  doctest ExDbmigrate

  test "fetch results" do
    assert ExDbmigrate.fetch_results().num_rows > 0
  end
end
