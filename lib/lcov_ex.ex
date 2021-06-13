defmodule LcovEx do
  @moduledoc """
  Lcov file generator for Elixir projects.

  Go to https://github.com/dariodf/lcov_ex for installation and usage instructions.
  """

  alias LcovEx.{Formatter, Stats}

  def start(compile_path, opts) do
    log_info("Cover compiling modules ... ", opts)
    :cover.start()

    case :cover.compile_beam_directory(compile_path |> to_charlist) do
      results when is_list(results) ->
        :ok

      {:error, _} ->
        Mix.raise("Failed to cover compile directory: " <> compile_path)
    end

    output = opts[:output]
    ignored_paths = Keyword.get(opts, :ignore_paths, [])

    fn ->
      log_info("\nGenerating lcov file ... ", opts)

      lcov =
        :cover.modules()
        |> Enum.sort()
        |> Enum.map(&calculate_module_coverage(&1, ignored_paths))

      File.mkdir_p!(output)
      path = "#{output}/lcov.info"
      File.write!(path, lcov, [:write])
      log_info("\nFile successfully created at #{path}", opts)
    end
  end

  defp calculate_module_coverage(mod, ignored_paths) do
    path = mod.module_info(:compile)[:source] |> to_string() |> Path.relative_to_cwd()

    if Enum.any?(ignored_paths, &String.starts_with?(path, &1)) do
      []
    else
      calculate_and_format_coverage(mod, path)
    end
  end

  defp calculate_and_format_coverage(mod, path) do
    {:ok, fun_data} = :cover.analyse(mod, :calls, :function)
    {functions_coverage, %{fnf: fnf, fnh: fnh}} = Stats.function_coverage_data(fun_data)

    {:ok, lines_data} = :cover.analyse(mod, :calls, :line)
    {lines_coverage, %{lf: lf, lh: lh}} = Stats.line_coverage_data(lines_data)

    Formatter.format_lcov(mod, path, functions_coverage, fnf, fnh, lines_coverage, lf, lh)
  end

  defp log_info(msg, opts) do
    unless Keyword.get(opts, :quiet, false) do
      Mix.shell().info(msg)
    end
  end
end
