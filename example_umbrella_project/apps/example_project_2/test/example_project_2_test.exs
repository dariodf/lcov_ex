defmodule ExampleProject2Test do
  use ExUnit.Case
  doctest ExampleProject2

  test "run covered function" do
    assert ExampleProject2.covered() == :covered
  end
end
