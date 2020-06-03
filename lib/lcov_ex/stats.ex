defmodule LcovEx.Stats do
  @moduledoc """
  Output parser for `:cover.analyse/3`
  """
  @type cover_analyze_function_output :: [{{module(), atom(), integer()}, integer()}, ...]
  @type cover_analyze_line_output :: [{{module(), integer()}, integer()}, ...]
  @type coverage_info :: {binary(), integer()}

  @doc """
  Function coverage data parser. Discards BEAM file `:__info__/1` function data.

  ## Examples

      iex> LcovEx.Stats.function_coverage_data([{{MyModule, :__info__, 1}, 3}, {{MyModule, :foo, 2}, 0}])
      {[{"foo/2", 0}], %{fnf: 1, fnh: 0}}

  """
  @spec function_coverage_data(cover_analyze_function_output()) ::
          {[coverage_info(), ...], %{fnf: integer(), fnh: integer()}}
  def function_coverage_data(fun_data) do
    Enum.reduce_while(fun_data, {[], %{fnf: 0, fnh: 0}}, fn data, acc = {list, %{fnf: fnf, fnh: fnh}} ->
      # TODO get FN + line by inspecting file
      case data do
        {{_, :__info__, _1}, _} ->
          {:cont, acc}

        {{_mod, name, arity}, count} ->
          {:cont,
           {list ++ [{"#{name}/#{arity}", count}],
            %{fnf: fnf + 1, fnh: fnh + ((count > 0 && 1) || 0)}}}
      end
    end)
  end

  @doc """
  Function coverage data parser. Discards BEAM file line `0` data.

  ## Examples

      iex> LcovEx.Stats.line_coverage_data([{{MyModule, 0}, 3}, {{MyModule, 0}, 0}, {{MyModule, 8}, 0}])
      {[{"8", 0}], %{lf: 1, lh: 0}}

  """
  @spec line_coverage_data(cover_analyze_line_output()) ::
          {[coverage_info(), ...], %{lf: integer(), lh: integer()}}
  def line_coverage_data(lines_data) do
    Enum.reduce_while(lines_data, {[], %{lf: 0, lh: 0}}, fn data, acc = {list, %{lf: lf, lh: lh}} ->
      case data do
        {{_, 0}, _} ->
          {:cont, acc}

        {{_mod, line}, count} ->
          {:cont, {list ++ [{"#{line}", count}], %{lf: lf + 1, lh: lh + ((count > 0 && 1) || 0)}}}
      end
    end)
  end
end
