defmodule ExampleProject do
  @moduledoc false

  def covered() do
    ExampleProject.ExampleModule.cover()
  end

  def mocked(module) do
    ExampleProject.ExampleBehaviour.call(module)
  end

  def not_covered() do
    ExampleProject.ExampleModule.cover()
  end
end
