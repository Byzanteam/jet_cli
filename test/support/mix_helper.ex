defmodule MixHelper do
  @moduledoc false

  import ExUnit.Assertions

  @spec in_repo(Path.t(), (() -> returning)) :: returning when returning: term()
  def in_repo(dir, function) do
    prev_cd = File.cwd!()

    try do
      File.cd!(dir)
      function.()
    after
      File.cd!(prev_cd)
    end
  end

  @spec assert_file(Path.t()) :: term()
  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  @spec assert_file(Path.t(), [match] | match | (binary() -> term())) :: term()
        when match: String.t() | Regex.t()
  def assert_file(file, match) do
    cond do
      is_list(match) ->
        assert_file(file, &Enum.each(match, fn m -> assert &1 =~ m end))

      is_binary(match) or is_struct(match, Regex) ->
        assert_file(file, &assert(&1 =~ match))

      is_function(match, 1) ->
        assert_file(file)
        assert match.(File.read!(file))

      true ->
        raise inspect({file, match})
    end
  end
end
