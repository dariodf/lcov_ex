defmodule Mix.Tasks.Lcov do
  @moduledoc "Generates lcov test coverage files for the application"
  @shortdoc "Generates lcov files"

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
    args = Enum.join(args ++ ["--cwd #{cwd}"], " ")

    # Script to load LcovEx modules and tasks from beam files on runtime, and then run `lcov.run`
    script = """
    # Get beam file data
    beam_path = System.argv() |> Enum.at(-2)
    beam_dir = Path.dirname(beam_path)
    beam_extension = Path.extname(beam_path)
    # Load all modules
    for filename <- File.ls!(beam_dir) |> Enum.filter(&String.ends_with?(&1, beam_extension)) do
      binary = File.read!(Path.join(beam_dir, filename));
      :code.load_binary(Path.rootname(filename) |> String.to_atom(), to_charlist(filename), binary);
    end
    # Load tasks
    Mix.Task.load_tasks([beam_dir])
    # Run lcov.run
    {task, args} = System.argv() |> Enum.at(-1) |> String.split() |> List.pop_at(0);
    Mix.Task.run(task, args)
    """

    beam_path = LcovEx |> :code.which() |> to_string()

    test_exit_code =
      Mix.shell().cmd(
        """
        mix run -e "#{script}" #{beam_path} "lcov.run #{args}"
        """,
        cd: path,
        env: [{"MIX_ENV", "test"}]
      )

    cond do
      is_nil(opts[:exit]) ->
        :ok

      test_exit_code == 0 ->
        :ok

      true ->
        # exit with the same exit code as the tests
        System.at_exit(fn _ -> exit({:shutdown, test_exit_code}) end)
    end

    # Umbrella projects support
    if Mix.Project.umbrella?() && path == cwd do
      # Setup folder, reset file
      output = opts[:output] || "cover"
      file_path = "#{output}/lcov.info"
      File.mkdir_p!(output)
      File.rm(file_path)

      # Write to single umbrella file
      for {_app, path} <- Mix.Project.apps_paths() do
        app_lcov_path = Path.join(path, file_path)
        app_lcov = app_lcov_path |> File.read!()

        File.write!(file_path, app_lcov, [:append])

        unless opts[:keep] do
          File.rm!(app_lcov_path)
        end
      end

      log_info("\nCoverage file for umbrella created at #{file_path}", opts)
    end

    :ok
  end

  defp log_info(msg, opts) do
    unless Keyword.get(opts, :quiet, false) do
      Mix.shell().info(msg)
    end
  end
end
