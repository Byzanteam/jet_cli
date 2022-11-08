defmodule JetCli.Injector.DepsTest do
  use ExUnit.Case, async: true

  alias JetCli.Injector.Deps

  test "injects deps" do
    content = """
    defmodule MixProject do
      defp deps do
        [
          {:b, "~> 2.0"}
        ]
      end
    end
    """

    content = Deps.inject(content, [{:a, "~> 1.0", runtime: false}])
    assert content =~ ":a"
    assert content =~ "~> 1.0"
    assert content =~ "runtime: false"
  end

  test "injects deps into empty deps" do
    content = """
    defmodule MixProject do
      defp deps do
        []
      end
    end
    """

    content = Deps.inject(content, [{:a, "~> 1.0", runtime: false}])
    assert content =~ ":a"
    assert content =~ "~> 1.0"
    assert content =~ "runtime: false"
  end

  test "raise error when the dep exists" do
    content = """
    defmodule MixProject do
      defp deps do
        []
      end
    end
    """

    content = Deps.inject(content, [{:a, "~> 1.0", runtime: false}])

    assert_raise Mix.Error, ~r/conflict/, fn ->
      Deps.inject(content, [{:a, "~> 1.0", runtime: false}])
    end
  end
end
