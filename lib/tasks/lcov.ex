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
    {lcov_args, test_args} = LcovEx.ArgParser.split_on_terminator(args)

    {opts, files} =
      OptionParser.parse!(lcov_args, strict: [quiet: :boolean, keep: :boolean, output: :string])

    if opts[:quiet], do: Mix.shell(Mix.Shell.Quiet)

    path = Enum.at(files, 0) || File.cwd!()

    # Setup folder, reset file
    output = opts[:output] || "cover"
    file_path = "#{output}/lcov.info"
    File.mkdir_p!(output)
    File.rm(file_path)

    # Actually run tests and coverage
    lcov_args = Enum.join(lcov_args, " ")
    test_args = Enum.join(test_args, " ")

    Mix.shell().cmd(
      "mix lcov.run #{lcov_args} -- #{test_args}",
      cd: path,
      env: [{"MIX_ENV", "test"}]
    )

    # Umbrella projects support
    if Mix.Project.umbrella?() do
      for {app, path} <- Mix.Project.apps_paths() do
        app_lcov_path = Path.join(path, file_path)
        app_lcov = app_lcov_path |> File.read!() |> String.replace("SF:", "SF:#{path}/")

        File.write!(file_path, app_lcov, [:append])

        if opts[:keep] do
          log_info("Coverage file for #{app} created at #{app_lcov_path}", opts)
        else
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
