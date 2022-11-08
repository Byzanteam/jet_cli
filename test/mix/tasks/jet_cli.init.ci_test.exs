defmodule Mix.Tasks.JetCli.Init.CiTest do
  use ExUnit.Case, async: true

  import MixHelper
  alias Mix.Tasks.JetCli.Init.Ci

  @tag :tmp_dir
  test "generates workflow files", %{tmp_dir: tmp_dir} do
    File.write!(
      Path.expand(".tool-versions", tmp_dir),
      """
      erlang 25.0
      elixir 1.14.0
      """
    )

    Ci.run([tmp_dir])

    in_repo(tmp_dir, fn ->
      assert_file(".github/workflows/prepare-ci/action.yml", ["25.0", "1.14.0"])

      assert_file(".github/workflows/elixir.yml", fn file ->
        refute file =~ "postgres"
      end)
    end)
  end

  @tag :tmp_dir
  test "generates workflow files, and setup the database", %{tmp_dir: tmp_dir} do
    File.write!(
      Path.expand(".tool-versions", tmp_dir),
      """
      erlang 25.0
      elixir 1.14.0
      """
    )

    Ci.run([tmp_dir, "--enable-database"])

    in_repo(tmp_dir, fn ->
      assert_file(".github/workflows/prepare-ci/action.yml", ["25.0", "1.14.0"])

      assert_file(".github/workflows/elixir.yml", fn file ->
        assert file =~ "postgres"
      end)
    end)
  end

  test "PATH is required", context do
    assert_raise Mix.Error, ~r/The PATH dose not exist, or it is not a directory/, fn ->
      Ci.run(["not-existing"])
    end

    assert_raise Mix.Error, ~r/The PATH dose not exist, or it is not a directory/, fn ->
      Ci.run([context.file])
    end
  end

  test ".tool-versions is required" do
    assert_raise Mix.Error, ~r/`.tool-versions` file dose not exist/, fn ->
      Ci.run([])
    end
  end
end
