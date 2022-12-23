defmodule LcovEx.ArgParser do
  @spec split_on_terminator([String.t()]) :: {[String.t()], [String.t()]}
  def split_on_terminator([]), do: {[], []}

  def split_on_terminator(args) do
    idx = Enum.find_index(args, fn s -> s == "--" end)
    split_at(args, idx)
  end

  defp split_at(args, _idx = nil), do: {args, []}

  defp split_at(args, idx) do
    {lhs, rhs} = Enum.split(args, idx)
    # `--` most be dropped
    rhs = tl(rhs)
    {lhs, rhs}
  end
end
