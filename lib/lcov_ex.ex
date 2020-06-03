defmodule LcovEx do
  @moduledoc """
  Lcov file generator for Elixir projects.

  Go to https://github.com/dariodf/lcov_ex for installation and usage instructions.
  """

  alias LcovEx.{Formatter, Stats}

  def start(compile_path, opts) do
    Mix.shell().info("Cover compiling modules ... ")
    :cover.start()

    case :cover.compile_beam_directory(compile_path |> to_charlist) do
      results when is_list(results) ->
        :ok

      {:error, _} ->
        Mix.raise("Failed to cover compile directory: " <> compile_path)
    end

    output = opts[:output]

    fn ->
      Mix.shell().info("\nGenerating lcov file ... ")

      lcov =
        Enum.map(:cover.modules() |> Enum.sort(), fn mod ->
          path = mod.module_info(:compile)[:source] |> to_string() |> Path.relative_to_cwd()

          {:ok, fun_data} = :cover.analyse(mod, :calls, :function)
          {functions_coverage, %{fnf: fnf, fnh: fnh}} = Stats.function_coverage_data(fun_data)

          {:ok, lines_data} = :cover.analyse(mod, :calls, :line)
          {lines_coverage, %{lf: lf, lh: lh}} = Stats.line_coverage_data(lines_data)

          Formatter.format_lcov(mod, path, functions_coverage, fnf, fnh, lines_coverage, lf, lh)
        end)
        |> Enum.join()

      File.mkdir_p!(output)
      path = "#{output}/lcov.info"
      File.write!(path, lcov, [:write])
      Mix.shell().info("\nFile successfully created at #{path}")
    end
  end
end
