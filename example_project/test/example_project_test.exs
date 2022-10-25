defmodule ExampleProjectTest do
  use ExUnit.Case
  doctest ExampleProject
  import Mox

  test "run covered function" do
    assert ExampleProject.covered() == :covered
  end

  test "run mox" do
    expect(ExampleProject.ExampleBehaviour.Mox, :callback, fn -> :ok end)
    assert :ok == ExampleProject.mocked(ExampleProject.ExampleBehaviour.Mox)
  end
end
