defmodule LcovExTest do
  use ExUnit.Case
  alias LcovEx.Test.Support.MixFileHelper

  describe "ExampleProject" do
    setup context do
      mix_path = "#{File.cwd!()}/example_project/mix.exs" |> String.replace("//", "/")
      MixFileHelper.backup(mix_path)

      config = [
        test_coverage: [
          tool: LcovEx,
          ignore_paths: ["deps/"],
          ignore_modules: Map.get(context, :ignore_modules, [])
        ]
      ]

      MixFileHelper.update_project_config(mix_path, config)

      on_exit(fn ->
        # Cleanup
        MixFileHelper.recover(mix_path)
        File.rm("example_project/cover/lcov.info")
      end)
    end

    test "run mix test --cover with LcovEx" do
      assert {_, 0} = System.cmd("mix", ["test", "--cover"], cd: "example_project")

      assert File.read!("example_project/cover/lcov.info") ==
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
               TN:Elixir.ExampleProject.ExampleIgnoreModule
               SF:lib/example_project/example_ignore_module.ex
               FNDA:0,cover/0
               FNDA:0,get_value/0
               FNF:2
               FNH:0
               DA:5,0
               DA:8,0
               LF:2
               LH:0
               end_of_record
               TN:Elixir.ExampleProject.ExampleIgnoreRegexModule
               SF:lib/example_project/example_ignore_regex_module.ex
               FNDA:0,cover/0
               FNDA:0,get_value/0
               FNF:2
               FNH:0
               DA:5,0
               DA:8,0
               LF:2
               LH:0
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

    @tag ignore_modules: [ExampleProject.ExampleIgnoreModule, ~r/.*ExampleIgnoreRegex.*/]
    test "ignore_modules excludes atom and regex matches from the lcov file" do
      assert {_, 0} = System.cmd("mix", ["test", "--cover"], cd: "example_project")

      coverage = File.read!("example_project/cover/lcov.info")
      assert coverage =~ "TN:Elixir.ExampleProject.ExampleModule\n"
      assert coverage =~ "SF:lib/example_project/example_module.ex\n"
      refute coverage =~ "TN:Elixir.ExampleProject.ExampleIgnoreModule\n"
      refute coverage =~ "SF:lib/example_project/example_ignore_module.ex\n"
      refute coverage =~ "TN:Elixir.ExampleProject.ExampleIgnoreRegexModule\n"
      refute coverage =~ "SF:lib/example_project/example_ignore_regex_module.ex\n"
    end
  end
end
