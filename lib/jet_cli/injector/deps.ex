defmodule JetCli.Injector.Deps do
  @moduledoc """
  Inject deps into `mix.exs` file.
  """

  @typep dep_name() :: atom()
  @typep dep_requirement() :: String.t()
  @typep dep_opts() :: Keyword.t()

  @typep dep() ::
           {dep_name(), dep_requirement()}
           | {dep_name(), dep_opts()}
           | {dep_name(), dep_requirement(), dep_opts()}

  @spec inject(binary(), [dep()]) :: binary()
  def inject(content, deps) do
    {quoted, comments} = Code.string_to_quoted_with_comments!(content)

    quoted
    |> Macro.prewalk(fn
      {:defp, defp_meta, [{:deps, deps_meta, nil}, [do: old_deps]]} ->
        dep_names = MapSet.new(old_deps, &dep_name/1)

        conflict_dep =
          Enum.find(deps, fn dep ->
            MapSet.member?(dep_names, dep_name(dep))
          end)

        conflict_dep && Mix.raise("#{inspect(conflict_dep)} is conflict with existing deps.")

        {
          :defp,
          defp_meta,
          [
            {:deps, deps_meta, nil},
            [do: old_deps ++ Macro.escape(deps)]
          ]
        }

      other ->
        other
    end)
    |> Code.quoted_to_algebra(comments: comments)
    # https://github.com/elixir-lang/elixir/blob/c5151e6890b5ac8df13276459696f0f47a8e634b/lib/elixir/lib/macro.ex#L1128
    |> Inspect.Algebra.format(98)
    |> IO.iodata_to_binary()
    |> Kernel.<>("\n")
  end

  defp dep_name({:{}, _meta, [dep_name | _dep_requirement_and_opts]}), do: dep_name
  defp dep_name({dep_name, _dep_requirement_or_opts}), do: dep_name
  defp dep_name({dep_name, _dep_requirement, _dep_opts}), do: dep_name
end
