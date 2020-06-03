defmodule ExampleProjectTest do
  use ExUnit.Case
  doctest ExampleProject

  test "run covered function" do
    assert ExampleProject.covered() == :covered
  end
end
