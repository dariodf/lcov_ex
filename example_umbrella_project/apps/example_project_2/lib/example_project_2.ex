defmodule ExampleProject2 do
  @moduledoc false

  def covered() do
    ExampleProject2.ExampleModule.cover()
  end

  def not_covered() do
    ExampleProject2.ExampleModule.cover()
  end
end
