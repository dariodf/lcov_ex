defmodule ExampleProject2.ExampleModule do
  @moduledoc false

  def cover() do
    get_value()
  end

  defp get_value() do
    :covered
  end
end
