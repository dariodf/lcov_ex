defmodule ExampleProject.ExampleBehaviour do
  @moduledoc false
  @callback callback() :: any()

  @doc false
  def call(module), do: module.callback()
end
