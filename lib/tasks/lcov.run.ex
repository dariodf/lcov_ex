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
          fail_fast: :boolean,
          cwd: :string,
          partitions: :integer,
          no_compile: :boolean
        ]
      )

    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    # lcov.info file setup
    output = opts[:output] || "cover"
    file_path = "#{output}/lcov.info"
    File.mkdir_p!(output)
    File.rm(file_path)

    app_path = Enum.at(files, 0)

    # Update config for current project on runtime, preserving any other
    # :test_coverage options set in the project (e.g. :ignore_modules)
    test_coverage =
      Mix.Project.config()
      |> Keyword.get(:test_coverage, [])
      |> Keyword.merge(
        tool: LcovEx,
        output: output,
        cwd: opts[:cwd],
        keep: opts[:keep],
        app_path: app_path
      )
      |> Keyword.update(:ignore_paths, @ignored_paths, &Enum.uniq(&1 ++ @ignored_paths))

    config = [test_coverage: test_coverage]

    mix_path = Mix.Project.project_file()
    new_config = Mix.Project.config() |> Keyword.merge(config)
    project = Mix.Project.get()
    Mix.ProjectStack.pop()
    Mix.ProjectStack.push(project, new_config, mix_path)

    test_params =
      ["--cover", "--color"] ++
        if(app_path, do: [Path.join("#{app_path}", "test")], else: []) ++
        if(opts[:fail_fast], do: ["--max-failures", "1"], else: []) ++
        if(opts[:partitions], do: ["--partitions", "#{opts[:partitions]}"], else: []) ++
        if(opts[:no_compile], do: ["--no-compile"], else: [])

    # Run tests with updated :test_coverage configuration
    Mix.Task.run("test", test_params)
  end
end
