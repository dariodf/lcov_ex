defmodule ExampleProject do
  @moduledoc false

  def covered() do
    ExampleProject.ExampleModule.cover()
  end

  def not_covered() do
    ExampleProject.ExampleModule.cover()
  end
end
