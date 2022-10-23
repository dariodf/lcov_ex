defmodule Mix.Tasks.Lcov.Run do
  @moduledoc "Generates lcov test coverage files for the application"
  @shortdoc "Generates lcov files"
  @recursive true
  @preferred_cli_env :test

  use Mix.Task
  require Logger

  @doc """
  Generates the `lcov.info` file.
  """
  @impl Mix.Task
  def run(args) do
    {opts, _files} =
      OptionParser.parse!(args, strict: [quiet: :boolean, keep: :boolean, output: :string])

    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    output = opts[:output] || "cover"
    file_path = "#{output}/lcov.info"
    File.mkdir_p!(output)
    File.rm(file_path)

    config = [test_coverage: [tool: LcovEx, output: output]]

    # Update config for current project on runtime
    mix_path = Mix.Project.project_file()
    new_config = Mix.Project.config() |> Keyword.merge(config)
    project = Mix.Project.get()
    Mix.ProjectStack.pop()
    Mix.ProjectStack.push(project, new_config, mix_path)

    # Run tests with updated :test_coverage configuration
    Mix.Task.run("test", ["--cover", "--color"])

    :ok
  end
end
