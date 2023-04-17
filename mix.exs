for path <- :code.get_path(),
    Regex.match?(~r/jet_cli\-\d+\.\d+\.\d.*\/ebin$/, List.to_string(path)) do
  Code.delete_path(path)
end

defmodule JetCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :jet_cli,
      version: "0.2.4",
      elixir: "~> 1.14",
      description: "The CLI for Jet Team.",
      source_url: "https://github.com/Byzanteam/jet_cli",
      package: [
        name: "jet_cli",
        licenses: ["MIT"],
        files: ~w(lib templates mix.exs mix.lock .tool-versions README.md),
        links: %{
          "GitHub" => "https://github.com/Byzanteam/jet_cli"
        }
      ],
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix, :eex],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [extra_applications: [:logger, :eex]]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:jet_credo, github: "Byzanteam/jet_credo", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/support"]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end
end
