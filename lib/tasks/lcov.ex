defmodule Mix.Tasks.Lcov do
  @moduledoc "Generates lcov test coverage files for the application"
  @shortdoc "Generates lcov files"
  @load_and_run_task_script File.read!("./lib/tasks/lcov/load_and_run_task.exs")

  use Mix.Task
  require Logger

  @doc """
  Generates the `lcov.info` file.
  """
  @impl Mix.Task
  def run(args) do
    {opts, files} =
      OptionParser.parse!(args,
        strict: [quiet: :boolean, keep: :boolean, output: :string, exit: :boolean]
      )

    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    cwd = File.cwd!()
    path = Enum.at(files, 0) || cwd

    # Actually run tests and coverage
    task = "lcov.run"
    args = Enum.join(args ++ ["--cwd #{cwd}"], " ")

    # Script to load a mix task and related dependency modules from beam files on runtime if necessary,
    # and then run the task
    script = @load_and_run_task_script

    # .beam path for `lcov.run` task
    beam_path = Mix.Task.get(task) |> :code.which() |> to_string()

    test_exit_code =
      Mix.shell().cmd(
        """
        mix run -e "#{script}" #{beam_path} "#{task} #{args}"
        """,
        cd: path,
        env: [{"MIX_ENV", "test"}]
      )

    # --exit option makes the task exit with the same exit code as the tests
    if opts[:exit] && test_exit_code != 0,
      do: System.at_exit(fn _ -> exit({:shutdown, test_exit_code}) end)

    # Umbrella projects support
    if Mix.Project.umbrella?() && path == cwd, do: umbrella_support(opts)
    :ok
  end

  defp umbrella_support(opts) do
    # Setup folder, reset file
    output = opts[:output] || "cover"
    file_path = "#{output}/lcov.info"
    File.mkdir_p!(output)
    File.rm(file_path)

    # Append apps coverage to a single umbrella coverage file
    for {_app, path} <- Mix.Project.apps_paths() do
      app_lcov_path = Path.join(path, file_path)
      app_lcov = app_lcov_path |> File.read!()

      File.write!(file_path, app_lcov, [:append])

      # Remove unless --keep
      unless opts[:keep] do
        File.rm!(app_lcov_path)
      end
    end

    log_info("\nCoverage file for umbrella created at #{file_path}", opts)

    :ok
  end

  defp log_info(msg, opts) do
    unless Keyword.get(opts, :quiet, false) do
      Mix.shell().info(msg)
    end
  end
end
