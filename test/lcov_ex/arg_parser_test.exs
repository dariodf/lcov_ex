defmodule LcovEx.FormatterTest do
  use ExUnit.Case

  alias LcovEx.ArgParser

  describe "split_on_terminator/1" do
    test "empty args should break in two empty lists" do
      assert ArgParser.split_on_terminator([]) == {[], []}
    end

    test "if -- does not exists keep the args on the first part of the tuple" do
      args = ["--quiet", "--keep", "--output", "./here"]
      assert ArgParser.split_on_terminator(args) == {args, []}
    end

    test "split args if -- exists" do
      args = ["--quiet", "--keep", "--output", "./here", "--", "--only", "fake"]

      assert ArgParser.split_on_terminator(args) ==
               {["--quiet", "--keep", "--output", "./here"], ["--only", "fake"]}
    end

    test "accept -- as first argument" do
      args = ["--", "--only", "fake"]

      assert ArgParser.split_on_terminator(args) ==
               {[], ["--only", "fake"]}
    end

    test "accept -- as last argument" do
      args = ["--quiet", "--keep", "--output", "./here", "--"]

      assert ArgParser.split_on_terminator(args) ==
               {["--quiet", "--keep", "--output", "./here"], []}
    end

    test "accept -- as only argument" do
      args = ["--"]

      assert ArgParser.split_on_terminator(args) ==
               {[], []}
    end
  end
end
