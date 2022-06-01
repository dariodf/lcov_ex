defmodule ExampleProject2 do
  @moduledoc false

  def covered() do
    ExampleProject2.ExampleModule.cover()
  end

  def also_covered() do
    ExampleProject2.ExampleModule.cover()
  end
end
