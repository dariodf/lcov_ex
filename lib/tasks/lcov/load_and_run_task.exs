# Script to load a mix task and related dependency modules from beam files on runtime if necessary,
# and then run the task
beam_path = System.argv() |> Enum.at(-2)
task_module = Path.rootname(beam_path) |> String.to_atom()

unless Code.ensure_loaded?(task_module) do
  # Get beam files data
  beam_dir = Path.dirname(beam_path)
  beam_extension = Path.extname(beam_path)
  # Load all modules
  for filename <- File.ls!(beam_dir) |> Enum.filter(&String.ends_with?(&1, beam_extension)) do
    binary = File.read!(Path.join(beam_dir, filename))
    :code.load_binary(Path.rootname(filename) |> String.to_atom(), to_charlist(filename), binary)
  end

  # Load tasks
  Mix.Task.load_tasks([beam_dir])
end

# Run given task
{task, args} = System.argv() |> Enum.at(-1) |> String.split() |> List.pop_at(0)
Mix.Task.run(task, args)
