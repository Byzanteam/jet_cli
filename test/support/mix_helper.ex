defmodule MixHelper do
  @moduledoc false

  import ExUnit.Assertions

  def in_repo(dir, function) do
    prev_cd = File.cwd!()

    try do
      File.cd!(dir)
      function.()
    after
      File.cd!(prev_cd)
    end
  end

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  def assert_file(file, match) do
    cond do
      is_list(match) ->
        assert_file(file, &Enum.each(match, fn m -> assert &1 =~ m end))

      is_binary(match) or is_struct(match, Regex) ->
        assert_file(file, &assert(&1 =~ match))

      is_function(match, 1) ->
        assert_file(file)
        match.(File.read!(file))

      true ->
        raise inspect({file, match})
    end
  end
end
