defmodule LcovEx.Formatter do
  @moduledoc """
  Formatter for `lcov.info` file.

  See more information about lcov in https://manpages.debian.org/stretch/lcov/geninfo.1.en.html#FILES.
  """

  @type mod :: module()
  @type path :: binary()
  @type coverage_info :: {binary(), integer()}

  @newline "\n"

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
    [
      "TN:",
      Atom.to_string(mod),
      @newline,
      "SF:",
      path,
      @newline,
      fnda(functions_coverage),
      "FNF:",
      Integer.to_string(fnf),
      @newline,
      "FNH:",
      Integer.to_string(fnh),
      @newline,
      da(lines_coverage),
      "LF:",
      Integer.to_string(lf),
      @newline,
      "LH:",
      Integer.to_string(lh),
      @newline,
      "end_of_record",
      @newline
    ]
  end

  # FNDA:<execution count>,<function name>
  defp fnda(functions_coverage) do
    Enum.map(functions_coverage, fn {function_name, execution_count} ->
      ["FNDA:", Integer.to_string(execution_count), ?,, function_name, @newline]
    end)
  end

  # DA:<line number>,<execution count>[,<checksum>]
  defp da(lines_coverage) do
    Enum.map(lines_coverage, fn {line_number, execution_count} ->
      ["DA:", Integer.to_string(line_number), ?,, Integer.to_string(execution_count), @newline]
    end)
  end
end
