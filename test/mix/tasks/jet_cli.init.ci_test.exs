Mix.shell(Mix.Shell.Process)

defmodule Mix.Tasks.JetCLI.Init.CITest do
  use ExUnit.Case, async: true

  import MixHelper
  alias Mix.Tasks.JetCLI.Init.CI

  @moduletag :tmp_dir

  setup do
    decline_prompt()
  end

  setup :setup_project

  test "generates workflow files", %{tmp_dir: tmp_dir} do
    File.write!(
      Path.expand(".tool-versions", tmp_dir),
      """
      erlang 25.0
      elixir 1.14.0
      """
    )

    CI.run([tmp_dir])

    in_repo(tmp_dir, fn ->
      assert_file(".github/workflows/elixir.yml", fn file ->
        refute file =~ "postgres"
      end)
    end)
  end

  test "generates workflow files, and setup the database", %{tmp_dir: tmp_dir} do
    File.write!(
      Path.expand(".tool-versions", tmp_dir),
      """
      erlang 25.0
      elixir 1.14.0
      """
    )

    CI.run([tmp_dir, "--enable-database"])

    in_repo(tmp_dir, fn ->
      assert_file(".github/workflows/elixir.yml", fn file ->
        assert file =~ "postgres"
      end)
    end)
  end

  test "generates the .credo.exs file and skip incompatible rules", %{tmp_dir: tmp_dir} do
    CI.run([tmp_dir])

    in_repo(tmp_dir, fn ->
      assert_file(".credo.exs", fn file ->
        refute file =~ "LazyLogging"
      end)
    end)
  end

  test "generates the .credo.exs file", %{tmp_dir: tmp_dir} do
    File.write!(
      Path.expand(".tool-versions", tmp_dir),
      """
      erlang 25.0
      elixir 1.13.0
      """
    )

    CI.run([tmp_dir])

    in_repo(tmp_dir, fn ->
      assert_file(".credo.exs", fn file ->
        assert file =~ "LazyLogging"
      end)
    end)
  end

  test "PATH is required", context do
    assert_raise Mix.Error, ~r/The PATH dose not exist, or it is not a directory/, fn ->
      CI.run(["not-existing"])
    end

    assert_raise Mix.Error, ~r/The PATH dose not exist, or it is not a directory/, fn ->
      CI.run([context.file])
    end
  end

  test "mix.exs is required", %{tmp_dir: tmp_dir} do
    File.rm!(Path.expand("mix.exs", tmp_dir))

    assert_raise Mix.Error, ~r/`mix.exs` file dose not exist/, fn ->
      CI.run([tmp_dir])
    end
  end

  test ".tool-versions is required", %{tmp_dir: tmp_dir} do
    File.rm!(Path.expand(".tool-versions", tmp_dir))

    assert_raise Mix.Error, ~r/`.tool-versions` file dose not exist/, fn ->
      CI.run([tmp_dir])
    end
  end

  defp decline_prompt do
    send(self(), {:mix_shell_input, :yes?, false})

    :ok
  end

  defp setup_project(%{tmp_dir: tmp_dir}) do
    File.write!(
      Path.expand(".tool-versions", tmp_dir),
      """
      erlang 25.0
      elixir 1.14.0
      """
    )

    File.write!(
      Path.expand("mix.exs", tmp_dir),
      """
        defmodule JetCLITest.MixProject do
          use Mix.Project

          def project do
            [
              app: :jet_cli_test,
              version: "0.1.0",
              elixir: "~> 1.14",
              start_permanent: Mix.env() == :prod,
              elixirc_paths: elixirc_paths(Mix.env()),
              deps: deps()
            ]
          end

          def application do
            [
              extra_applications: [:logger]
            ]
          end

          defp deps do
            []
          end

          defp elixirc_paths(:test), do: ["lib", "test/support"]
          defp elixirc_paths(_), do: ["lib"]
        end
      """
    )
  end
end
