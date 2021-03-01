defmodule LcovEx.FormatterTest do
  use ExUnit.Case

  describe "ExampleProject" do
    test "run mix test --cover with LcovEx" do
      assert LcovEx.Formatter.format_lcov(
               FakeModule,
               "path/to/file.ex",
               [{"foo/0", 1}, {"bar/2", 0}],
               2,
               1,
               [{"3", 1}, {"5", 0}],
               2,
               1
             ) ==
               """
               TN:Elixir.FakeModule
               SF:path/to/file.ex
               FNDA:1,foo/0
               FNDA:0,bar/2
               FNF:2
               FNH:1
               DA:3,1
               DA:5,0
               LF:2
               LH:1
               end_of_record
               """
    end
  end
end
