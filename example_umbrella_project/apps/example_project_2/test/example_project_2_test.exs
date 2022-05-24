defmodule ExampleProject2Test do
  use ExUnit.Case
  doctest ExampleProject

  test "run covered function" do
    assert ExampleProject2.covered() == :covered
  end
end
