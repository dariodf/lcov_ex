defmodule Mix.Tasks.Lcov.Run do
  @moduledoc "Generates lcov test coverage files for the application"
  @shortdoc "Generates lcov files"
  @recursive true
  @preferred_cli_env :test

  # Ignore modules compiled by dependencies
  @ignored_paths ["deps/"]

  use Mix.Task
  require Logger

  @doc """
  Generates the `lcov.info` file.
  """
  @impl Mix.Task
  def run(args) do
    {opts, files} =
      OptionParser.parse!(args,
        strict: [
          quiet: :boolean,
          keep: :boolean,
          output: :string,
          exit: :boolean,
          cwd: :string
        ]
      )

    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    # lcov.info file setup
    output = opts[:output] || "cover"
    file_path = "#{output}/lcov.info"
    File.mkdir_p!(output)
    File.rm(file_path)

    arg_path = Enum.at(files, 0)

    # Update config for current project on runtime
    config = [
      test_coverage: [
        tool: LcovEx,
        output: output,
        ignore_paths: @ignored_paths,
        cwd: opts[:cwd],
        keep: opts[:keep],
        arg_path: arg_path
      ]
    ]

    mix_path = Mix.Project.project_file()
    new_config = Mix.Project.config() |> Keyword.merge(config)
    project = Mix.Project.get()
    Mix.ProjectStack.pop()
    Mix.ProjectStack.push(project, new_config, mix_path)

    arg_path_test_dir = Path.join("#{arg_path}", "test")
    # Run tests with updated :test_coverage configuration
    Mix.Task.run("test", ["--cover", "--color", "#{arg_path_test_dir}"])
  end
end
