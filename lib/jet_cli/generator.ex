defmodule JetCLI.Generator do
  @moduledoc false

  defmacro templates(files) do
    root = Path.expand("../../templates", __DIR__)

    Enum.map(files, fn name ->
      path = Path.expand(name, root)

      quote location: :keep do
        @external_resource unquote(path)

        defp template(unquote(name)), do: unquote(File.read!(path))
      end
    end)
  end
end
