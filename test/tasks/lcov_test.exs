defmodule LcovEx.Tasks.LcovTest do
  use ExUnit.Case, async: true

  describe "ExampleProject" do
    setup do
      on_exit(fn ->
        # Cleanup
        File.rm("example_project/cover/lcov.info")
      end)
    end

    test "lcov task" do
      Mix.Project.in_project(:example_project, "example_project", fn _module ->
        assert Mix.Tasks.Lcov.run([])
      end)

      assert File.read!("example_project/cover/lcov.info") == output()
    end

    test "mix lcov" do
      assert {output, 0} = System.cmd("mix", ["lcov"], cd: "example_project")

      assert output =~ "Generating lcov file..."
      assert output =~ "Coverage file created at cover/lcov.info"

      assert File.read!("example_project/cover/lcov.info") == output()
    end

    test "mix lcov --quiet" do
      assert {output, 0} = System.cmd("mix", ["lcov", "--quiet"], cd: "example_project")

      refute output =~ "Generating lcov file..."
      refute output =~ "Coverage file created at cover/lcov.info"

      assert File.read!("example_project/cover/lcov.info") == output()
    end

    test "mix lcov --output" do
      assert {output, 0} =
               System.cmd("mix", ["lcov", "--output", "coverage"], cd: "example_project")

      assert output =~ "Generating lcov file..."
      assert output =~ "Coverage file created at coverage/lcov.info"

      assert File.read!("example_project/coverage/lcov.info") == output()
    after
      File.rm_rf!("example_project/coverage")
    end

    test "mix lcov exits normally on failure" do
      assert {output, 0} = System.cmd("mix", ["lcov"], cd: "example_failing_project")

      assert output =~ "Generating lcov file..."
      assert output =~ "Coverage file created at cover/lcov.info"
    end

    test "mix lcov --exit returns a non-zero exit code on failure" do
      assert {output, 2} = System.cmd("mix", ["lcov", "--exit"], cd: "example_failing_project")

      assert output =~ "Generating lcov file..."
      assert output =~ "Coverage file created at cover/lcov.info"
    end
  end

  describe "ExampleUmbrellaProject" do
    setup do
      on_exit(fn ->
        # Cleanup
        File.rm("example_umbrella_project/cover/lcov.info")
        File.rm("example_umbrella_project/apps/example_project/cover/lcov.info")
        File.rm("example_umbrella_project/apps/example_project_2/cover/lcov.info")
      end)
    end

    test "lcov task" do
      Mix.Project.in_project(:example_umbrella_project, "example_umbrella_project", fn _module ->
        assert Mix.Tasks.Lcov.run([])
      end)

      assert File.read!("example_umbrella_project/cover/lcov.info") ==
               umbrella_output() <> umbrella_output_2()
    end

    test "mix lcov" do
      assert {output, 0} = System.cmd("mix", ["lcov"], cd: "example_umbrella_project")

      assert output =~ "Generating lcov file..."
      assert output =~ "Coverage file for umbrella created at cover/lcov.info"
      refute output =~ "apps/example_project/cover/lcov.info"
      refute output =~ "apps/example_project_2/cover/lcov.info"

      assert File.read!("example_umbrella_project/cover/lcov.info") ==
               umbrella_output() <> umbrella_output_2()
    end

    test "mix lcov --keep" do
      assert {output, 0} = System.cmd("mix", ["lcov", "--keep"], cd: "example_umbrella_project")

      assert output =~ "Generating lcov file..."

      assert output =~
               "Coverage file for example_project created at apps/example_project/cover/lcov.info"

      assert output =~
               "Coverage file for example_project_2 created at apps/example_project_2/cover/lcov.info"

      assert output =~ "Coverage file for umbrella created at cover/lcov.info"

      assert File.read!("example_umbrella_project/cover/lcov.info") ==
               umbrella_output() <> umbrella_output_2()
    end

    test "mix lcov on umbrella app without the dependency" do
      assert {output, 0} =
               System.cmd("mix", ["lcov", "apps/example_project_2"],
                 cd: "example_umbrella_project"
               )

      assert output =~ "Generating lcov file..."
      assert output =~ "Coverage file created at apps/example_project_2/cover/lcov.info"

      assert File.read!("example_umbrella_project/apps/example_project_2/cover/lcov.info") ==
               umbrella_output_2()
    end
  end

  defp output do
    """
    TN:Elixir.ExampleProject
    SF:lib/example_project.ex
    FNDA:1,covered/0
    FNDA:1,mocked/1
    FNDA:0,not_covered/0
    FNF:3
    FNH:2
    DA:5,1
    DA:9,1
    DA:13,0
    LF:3
    LH:2
    end_of_record
    TN:Elixir.ExampleProject.ExampleBehaviour
    SF:lib/example_project/example_behaviour.ex
    FNDA:1,call/1
    FNF:1
    FNH:1
    DA:6,1
    LF:1
    LH:1
    end_of_record
    TN:Elixir.ExampleProject.ExampleModule
    SF:lib/example_project/example_module.ex
    FNDA:1,cover/0
    FNDA:1,get_value/0
    FNF:2
    FNH:2
    DA:5,1
    DA:8,1
    LF:2
    LH:2
    end_of_record
    """
  end

  defp umbrella_output do
    """
    TN:Elixir.ExampleProject
    SF:apps/example_project/lib/example_project.ex
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
    SF:apps/example_project/lib/example_project/example_module.ex
    FNDA:1,cover/0
    FNDA:1,get_value/0
    FNF:2
    FNH:2
    DA:5,1
    DA:8,1
    LF:2
    LH:2
    end_of_record
    """
  end

  defp umbrella_output_2 do
    """
    TN:Elixir.ExampleProject2
    SF:apps/example_project_2/lib/example_project_2.ex
    FNDA:1,also_covered/0
    FNDA:1,covered/0
    FNF:2
    FNH:2
    DA:5,1
    DA:9,1
    LF:2
    LH:2
    end_of_record
    TN:Elixir.ExampleProject2.ExampleModule
    SF:apps/example_project_2/lib/example_project_2/example_module.ex
    FNDA:2,cover/0
    FNDA:2,get_value/0
    FNF:2
    FNH:2
    DA:5,2
    DA:8,2
    LF:2
    LH:2
    end_of_record
    """
  end
end
