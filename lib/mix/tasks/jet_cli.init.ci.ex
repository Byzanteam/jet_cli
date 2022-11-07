defmodule Mix.Tasks.JetCli.Init.Ci do
  use Mix.Task

  import Mix.Generator

  @shortdoc "Init CI (GitHub Actions) for the Elixir project"

  @moduledoc """
  Init CI (GitHub Actions) for the Elixir project.

      mix jet_cli.init.ci [DIR] [--enable-database]
  """

  @switches [
    enable_database: :boolean
  ]

  @impl true
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches)

    dir =
      case argv do
        [dir | _rest] -> Path.expand(dir)
        [] -> File.cwd()
      end

    check_project_directory(dir)
    ensure_ci_directory!(dir)
    versions = check_tool_versions!(dir)

    copy_template(
      "templates/workflows/prepare-ci/action.yml",
      file_path(dir, ".github/workflows/prepare-ci/action.yml"),
      elixir_version: Keyword.fetch!(versions, :elixir),
      erlang_version: Keyword.fetch!(versions, :erlang)
    )

    copy_template(
      "templates/workflows/elixir.yml",
      file_path(dir, ".github/workflows/elixir.yml"),
      enable_database: Keyword.get(opts, :enable_database, false)
    )
  end

  defp check_project_directory(dir) do
    unless File.dir?(dir) do
      Mix.raise("The PATH dose not exist, or it is not a directory")
    end
  end

  @tool_versions_file ".tool-versions"

  defp check_tool_versions!(base_dir) do
    file = Path.expand(base_dir, @tool_versions_file)

    unless File.exists?(file) do
      Mix.raise("`#{@tool_versions_file}` file dose not exist under `#{base_dir}`")
    end

    case File.read(file) do
      {:ok, content} ->
        extract_tool_versions!(content)

      {:error, reason} ->
        Mix.raise(
          "Can not read the `#{@tool_versions_file}` file at `#{file}` for #{inspect(reason)}"
        )
    end
  end

  @permitted_name ~w[elixir erlang]
  defp extract_tool_versions!(content) do
    content
    |> String.split(~r/\n/)
    |> Stream.map(&String.split(&1, ~r/\s/))
    |> Stream.filter(&Enum.member?(@permitted_name, &1))
    |> Stream.map(fn [name, version] ->
      {String.to_existing_atom(name), version}
    end)
    |> Enum.to_list()
    |> case do
      [_first, _second] = versions ->
        versions

      versions ->
        Mix.raise("The elixir and erlang versions should be both set, got #{inspect(versions)}")
    end
  end

  @ci_directory ".github/workflows/"

  defp ensure_ci_directory!(base_dir) do
    base_dir
    |> Path.expand(@ci_directory)
    |> Mix.Generator.create_directory()
  end

  defp file_path(base_dir, name) do
    Path.expand(base_dir, name)
  end
end
