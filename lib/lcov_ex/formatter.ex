defmodule LcovEx.Formatter do
  @moduledoc """
  Formatter for `lcov.info` file.

  See more information about lcov in https://manpages.debian.org/stretch/lcov/geninfo.1.en.html#FILES.
  """

  @type mod :: module()
  @type path :: binary()
  @type coverage_info :: {binary(), integer()}

  @doc """
  Create a lcov specification for a module.
  """
  @spec format_lcov(
          mod(),
          path(),
          [coverage_info(), ...],
          integer(),
          integer(),
          [coverage_info(), ...],
          integer(),
          integer()
        ) :: binary()
  def format_lcov(mod, path, functions_coverage, fnf, fnh, lines_coverage, lf, lh) do
    # TODO FN
    """
    TN:#{mod}
    SF:#{path}
    #{fnda(functions_coverage)}
    FNF:#{fnf}
    FNH:#{fnh}
    #{da(lines_coverage)}
    LF:#{lf}
    LH:#{lh}
    end_of_record
    """
  end

  # FNDA:<execution count>,<function name>
  defp fnda(functions_coverage) do
    Enum.map(functions_coverage, fn {function_name, execution_count} ->
      "FNDA:#{execution_count},#{function_name}"
    end)
    |> Enum.join("\n")
  end

  # DA:<line number>,<execution count>[,<checksum>]
  defp da(lines_coverage) do
    Enum.map(lines_coverage, fn {line_number, execution_count} ->
      "DA:#{line_number},#{execution_count}"
    end)
    |> Enum.join("\n")
  end
end
