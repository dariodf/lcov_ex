defmodule ExampleProject2Test do
  use ExUnit.Case
  doctest ExampleProject2

  test "run covered function" do
    assert ExampleProject2.covered() == :covered
  end

  test "run also covered function" do
    assert ExampleProject2.also_covered() == :covered
  end
end
