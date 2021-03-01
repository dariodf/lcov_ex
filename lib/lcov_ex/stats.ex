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
    Enum.reduce_while(fun_data, {[], %{fnf: 0, fnh: 0}}, fn data,
                                                            acc = {list, %{fnf: fnf, fnh: fnh}} ->
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

      iex> LcovEx.Stats.line_coverage_data([{{MyModule, 1}, 12}, {{MyModule, 1}, 0}, {{MyModule, 2}, 0}])
      {[{"1", 12}, {"2", 0}], %{lf: 2, lh: 1}}

  """
  @spec line_coverage_data(cover_analyze_line_output()) ::
          {[coverage_info(), ...], %{lf: integer(), lh: integer()}}
  def line_coverage_data(lines_data) do
    {list_reversed, _previous_line, lf, lh} =
      Enum.reduce(lines_data, {[], nil, 0, 0}, fn data, acc = {list, previous_line, lf, lh} ->
        case data do
          {{_, 0}, _} ->
            acc

          {^previous_line, count} ->
            [{line_str, previous_count} | rest] = list
            count = max(count, previous_count)

            lh = increment_line_hit(lh, count, previous_count)

            {[{line_str, count} | rest], previous_line, lf, lh}

          {{_mod, line} = previous_line, count} ->
            list = [{"#{line}", count} | list]
            lf = lf + 1
            lh = increment_line_hit(lh, count, 0)
            {list, previous_line, lf, lh}
        end
      end)

    {Enum.reverse(list_reversed), %{lf: lf, lh: lh}}
          end

  defp increment_line_hit(lh, count, previous_count)
  defp increment_line_hit(lh, 0, _), do: lh
  defp increment_line_hit(lh, _count, 0), do: lh + 1
  defp increment_line_hit(lh, _, _), do: lh
end
