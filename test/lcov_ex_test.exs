defmodule LcovExTest do
  use ExUnit.Case
  alias LcovEx.Test.Support.MixFileHelper

  describe "ExampleProject" do
    setup do
      mix_path = "#{File.cwd!()}/example_project/mix.exs" |> String.replace("//", "/")
      MixFileHelper.backup(mix_path)
      config = [test_coverage: [tool: LcovEx]]
      MixFileHelper.update_project_config(mix_path, config)

      on_exit(fn ->
        # Cleanup
        MixFileHelper.recover(mix_path)
        File.rm("example_project/cover/lcov.info")
      end)
    end

    test "run mix test --cover with LcovEx" do
      System.cmd("mix", ["test", "--cover"], cd: "example_project")

      assert File.read!("example_project/cover/lcov.info") ==
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
               DA:8,1
               LF:2
               LH:2
               end_of_record
               """
    end
  end
end
