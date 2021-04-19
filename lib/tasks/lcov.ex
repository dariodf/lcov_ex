defmodule Mix.Tasks.Lcov do
  @moduledoc "Generates lcov test coverage files for the application"
  @shortdoc "Generates lcov files"
  @preferred_cli_env :test
  @recursive true

  use Mix.Task
  alias LcovEx.MixFileHelper

  @doc """
  Generates the `lcov.info` file.
  """
  @impl Mix.Task
  def run(args) do
    path = Enum.at(args, 0) || File.cwd!()
    mix_path = "#{path}/mix.exs" |> String.replace("//", "/")
    MixFileHelper.backup(mix_path)

    try do
      config = [test_coverage: [tool: LcovEx]]
      MixFileHelper.update_project_config(mix_path, config)
      System.cmd("mix", ["test", "--cover"], cd: path, into: IO.stream(:stdio, :line))
    after
      MixFileHelper.recover(mix_path)
    end
  end
end
