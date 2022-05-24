defmodule LcovEx.Tasks.LcovTest do
  use ExUnit.Case, async: true

  describe "ExampleProject" do
    test "lcov task" do
      assert Mix.Tasks.Lcov.run(["./example_project"])

      assert File.read!("example_project/cover/lcov.info") == output()
      # Cleanup
      File.rm("example_project/cover/lcov.info")
    end

    test "mix lcov" do
      assert {output, 0} = System.cmd("mix", ["lcov"], cd: "example_project")

      assert output =~ "Generating lcov file ..."
      assert output =~ "File successfully created at cover/lcov.info"

      assert File.read!("example_project/cover/lcov.info") == output()

      # Cleanup
      File.rm("example_project/cover/lcov.info")
    end

    test "mix lcov --quiet" do
      assert {output, 0} = System.cmd("mix", ["lcov", "--quiet"], cd: "example_project")

      refute output =~ "Generating lcov file ..."
      refute output =~ "File successfully created at cover/lcov.info"

      assert File.read!("example_project/cover/lcov.info") == output()

      # Cleanup
      File.rm("example_project/cover/lcov.info")
    end

    test "mix lcov for umbrella project" do
      assert {output, 0} =
               System.cmd("mix", ["lcov"], cd: "example_umbrella_project")

      assert output =~ "Generating lcov file ..."
      assert output =~ "File successfully created at apps/example_project/cover/lcov.info"
      assert output =~ "File successfully created at apps/example_project_2/cover/lcov.info"

      assert File.read!("example_umbrella_project/apps/example_project/cover/lcov.info") ==
               output()

      assert File.read!("example_umbrella_project/apps/example_project_2/cover/lcov.info") ==
               output_2()

      # Cleanup
      File.rm("example_umbrella_project/apps/example_project/cover/lcov.info")
    end
  end

  defp output do
    """
    TN:Elixir.ExampleProject
    SF:lib/example_project.ex
    FNDA:1,covered/0
    FNDA:0,not_covered/0
    FNF:2
    FNH:1
    DA:5,1
    DA:9,0
    LF:2
    LH:1
    end_of_record
    TN:Elixir.ExampleProject.ExampleModule
    SF:lib/example_project/example_module.ex
    FNDA:1,cover/0
    FNDA:1,get_value/0
    FNF:2
    FNH:2
    DA:5,1
    LF:1
    LH:1
    end_of_record
    """
  end

  defp output_2 do
    """
    TN:Elixir.ExampleProject2
    SF:lib/example_project_2.ex
    FNDA:1,covered/0
    FNDA:0,not_covered/0
    FNF:2
    FNH:1
    DA:5,1
    DA:9,0
    LF:2
    LH:1
    end_of_record
    TN:Elixir.ExampleProject2.ExampleModule
    SF:lib/example_project_2/example_module.ex
    FNDA:1,cover/0
    FNDA:1,get_value/0
    FNF:2
    FNH:2
    DA:5,1
    LF:1
    LH:1
    end_of_record
    """
  end
end
