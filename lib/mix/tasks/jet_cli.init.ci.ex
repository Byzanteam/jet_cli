defmodule Mix.Tasks.JetCli.Init.Ci do
  use Mix.Task

  import Mix.Generator

  @shortdoc "Init CI (GitHub Actions) for the Elixir project"

  @moduledoc """
  Init CI (GitHub Actions) for the Elixir project.

      mix jet_cli.init.ci [DIR] [--enable-database]

  ## Options

    * `--enable-database` - generate the database service
  """

  @switches [
    enable_database: :boolean
  ]

  @impl true
  def run(args) do
    {opts, argv} = OptionParser.parse!(args, strict: @switches)

    dir =
      case argv do
        [dir | _rest] ->
          Path.expand(dir)

        [] ->
          {:ok, path} = File.cwd()
          path
      end

    check_project_directory!(dir)
    ensure_ci_directory!(dir)
    versions = check_tool_versions!(dir)

    copy_template(
      source_file("workflows/prepare-ci/action.yml"),
      target_file(".github/workflows/prepare-ci/action.yml", dir),
      elixir_version: Keyword.fetch!(versions, :elixir),
      erlang_version: Keyword.fetch!(versions, :erlang)
    )

    copy_template(
      source_file("workflows/elixir.yml"),
      target_file(".github/workflows/elixir.yml", dir),
      enable_database: Keyword.get(opts, :enable_database, false)
    )
  end

  defp check_project_directory!(dir) do
    unless File.dir?(dir) do
      Mix.raise("The PATH dose not exist, or it is not a directory")
    end
  end

  @tool_versions_file ".tool-versions"

  defp check_tool_versions!(base_dir) do
    file = Path.expand(@tool_versions_file, base_dir)

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

  @permitted_names ~w[elixir erlang]

  defp extract_tool_versions!(content) do
    content
    |> String.split(~r/\n/, trim: true)
    |> Stream.map(&String.split(&1, ~r/\s/))
    |> Stream.filter(fn [name, _version] -> name in @permitted_names end)
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
    @ci_directory
    |> Path.expand(base_dir)
    |> create_directory()
  end

  defp source_file(file) do
    root = Path.expand("../../../templates", __DIR__)

    Path.expand(file, root)
  end

  defp target_file(file, dir) do
    Path.expand(file, dir)
  end
end
