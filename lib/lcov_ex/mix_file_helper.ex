defmodule LcovEx.MixFileHelper do
  @type path :: binary()

  @doc """
  Backup file in path by duplicating it into an `.old` file.
  """
  @spec backup(path()) :: path()
  def backup(path) do
    path_old = "#{path}.old"
    File.cp!(path, path_old)
    path_old
  end

  @doc """
  Recover file in path from preexisting `.old` file.
  """
  @spec recover(path()) :: :ok
  def recover(path) do
    path_old = "#{path}.old"
    File.cp!(path_old, path)
    File.rm!(path_old)
    :ok
  end

  @doc """
  Update mix project configurations.
  """
  @spec update_project_config(path(), keyword()) :: :ok
  def update_project_config(mix_path, new_configs) do
    # Format mix.exs file
    System.cmd("mix", ["format", mix_path])

    # Get file as AST representation
    {:defmodule, _, [_, [do: {_, _, ast_nodes}]]} =
      Code.string_to_quoted!(File.read!(mix_path), token_metadata: true)

    # Obtain the project AST node
    project_ast_node =
      Enum.find(ast_nodes, fn ast -> match?({:def, _, [{:project, _, _}, _]}, ast) end)

    # Get project config and file start and ending line numbers for replacement
    {_, token_metadata, [project_ast_tuple, [do: config]]} = project_ast_node
    project_start_line = token_metadata[:line]
    project_end_line = token_metadata[:end_of_expression][:line]

    # Update the configs
    # We try to maintain the key positions or append any new configs to the bottom
    new_config =
      Enum.reduce(new_configs, config, fn {key, value}, config ->
        case Keyword.pop(config, key) do
          {nil, list} -> list ++ [{key, value}]
          _ -> put_in(config[key], value)
        end
      end)

    new_project_ast_node = put_elem(project_ast_node, 2, [project_ast_tuple, [do: new_config]])

    # Reconvert to string
    project_string_replacement =
      new_project_ast_node
      |> Macro.to_string()
      |> String.replace_prefix("def(project) do", "def project do")
      |> String.replace_suffix("end", "end\n")

    replace_range = project_start_line..project_end_line

    # Replace the project config into the file
    replace_range(mix_path, replace_range, project_string_replacement)

    # Format new mix.exs file
    System.cmd("mix", ["format", mix_path])
    :ok
  end

  @doc """
  Update mix deps.
  """
  @spec update_deps(path(), keyword()) :: :ok
  def update_deps(mix_path, new_deps) do
    # Format mix.exs file
    System.cmd("mix", ["format", mix_path])

    # Get file as AST representation
    {:defmodule, _, [_, [do: {_, _, ast_nodes}]]} =
      Code.string_to_quoted!(File.read!(mix_path), token_metadata: true)

    # Obtain the deps AST node
    deps_ast_node =
      Enum.find(ast_nodes, fn ast -> match?({:def, _, [{:deps, _, _}, _]}, ast) end)

    # Get deps and file start and ending line numbers for replacement
    {_, token_metadata, [deps_ast_tuple, [do: deps]]} = deps_ast_node
    deps_start_line = token_metadata[:line]
    deps_end_line = token_metadata[:end_of_expression][:line]

    # Update the deps
    # We try to maintain the key positions or append any new deps to the bottom
    new_deps =
      Enum.reduce(new_deps, deps, fn {key, value}, deps ->
        case Keyword.pop(deps, key) do
          {nil, list} -> list ++ [{key, value}]
          _ -> put_in(deps[key], value)
        end
      end)

    new_deps_ast_node = put_elem(deps_ast_node, 2, [deps_ast_tuple, [do: new_deps]])

    # Reconvert to string
    deps_string_replacement =
      new_deps_ast_node
      |> Macro.to_string()
      |> String.replace_prefix("def(deps) do", "def deps do")
      |> String.replace_suffix("end", "end\n")

    replace_range = deps_start_line..deps_end_line

    # Replace the deps config into the file
    replace_range(mix_path, replace_range, deps_string_replacement)

    # Format new mix.exs file
    System.cmd("mix", ["format", mix_path])
    :ok
  end

  #
  # Private functions
  #

  defp replace_range(path, range, replacement) when is_binary(replacement) do
    path_tmp = "#{path}.tmp"
    File.cp!(path, path_tmp)

    try do
      File.rm!(path)
      new_file = File.open!(path, [:append])

      File.open!(path_tmp, [:read], fn old_file ->
        copy_and_replace(old_file, new_file, range, replacement)
      end)
    catch
      _, _ ->
        File.cp!(path_tmp, path)
    after
      File.rm(path_tmp)
    end
  end

  defp copy_and_replace(old_file, new_file, range, string_replacement) do
    IO.read(old_file, :line)
    |> copy_and_replace(1, old_file, new_file, range, string_replacement)
  end

  defp copy_and_replace(:eof, _, _, _, _, _) do
    :ok
  end

  defp copy_and_replace(_, index, old_file, new_file, range_start.._ = range, string_replacement)
       when index == range_start do
    IO.write(new_file, string_replacement)

    IO.read(old_file, :line)
    |> copy_and_replace(index + 1, old_file, new_file, range, string_replacement)
  end

  defp copy_and_replace(line, index, old_file, new_file, range, string_replacement) do
    unless index in range, do: IO.write(new_file, line)

    IO.read(old_file, :line)
    |> copy_and_replace(index + 1, old_file, new_file, range, string_replacement)
  end
end
