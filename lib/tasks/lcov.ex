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
    {opts, files} =
      OptionParser.parse!(args, strict: [quiet: :boolean, keep: :boolean, output: :string])

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

    output = opts[:output] || "cover"
    file_path = "#{output}/lcov.info"
    File.mkdir_p!(output)
    File.rm(file_path)

    try do
      config = [test_coverage: [tool: LcovEx, output: output]]

      Enum.each(affected_files, fn mix_path ->
        MixFileHelper.update_project_config(mix_path, config)
      end)

      task_opts =
        if opts[:quiet] do
          [cd: path]
        else
          [cd: path, into: IO.stream(:stdio, :line)]
        end

      System.cmd("mix", ["test", "--cover"], task_opts)
    after
      if Mix.Project.umbrella?() do
        for {app, path} <- Mix.Project.apps_paths() do
          app_lcov_path = Path.join(path, file_path)
          File.write!(file_path, File.read!(app_lcov_path), [:append])

          if opts[:keep] do
            log_info("Coverage file for #{app} created at #{app_lcov_path}", opts)
          else
            File.rm!(app_lcov_path)
          end
        end

        log_info("\nCoverage file for umbrella created at #{file_path}", opts)
      end

      Enum.each(affected_files, fn mix_path -> MixFileHelper.recover(mix_path) end)
    end
  end

  defp log_info(msg, opts) do
    unless Keyword.get(opts, :quiet, false) do
      Mix.shell().info(msg)
    end
  end
end
