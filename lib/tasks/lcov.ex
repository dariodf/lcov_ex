defmodule Mix.Tasks.Lcov do
  @moduledoc "Generates lcov test coverage files for the application"
  @shortdoc "Generates lcov files"
  @preferred_cli_env :test

  use Mix.Task
  alias LcovEx.MixFileHelper
  require Logger

  @doc """
  Generates the `lcov.info` file.
  """
  @impl Mix.Task
  def run(args) do
    {opts, files} = OptionParser.parse!(args, strict: [quiet: :boolean])
    path = Enum.at(files, 0) || File.cwd!()

    affected_files =
      case Mix.Project.apps_paths() do
        nil ->
          [Path.join([path, "mix.exs"])]

        apps_paths ->
          for {_app, app_path} <- apps_paths, do: Path.join([path, app_path, "mix.exs"])
      end
      |> Enum.map(fn path -> String.replace(path, "//", "/") end)

    Enum.each(affected_files, fn mix_path -> MixFileHelper.backup(mix_path) end)

    try do
      config = [test_coverage: [tool: LcovEx]]

      Enum.each(affected_files, fn mix_path ->
        MixFileHelper.update_project_config(mix_path, config)
      end)

      opts =
        if opts[:quiet] do
          [cd: path]
        else
          [cd: path, into: IO.stream(:stdio, :line)]
        end

      System.cmd("mix", ["test", "--cover"], opts)
    after
      Enum.each(affected_files, fn mix_path -> MixFileHelper.recover(mix_path) end)
    end
  end
end
