defmodule JetCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :jet_cli,
      version: "0.1.0",
      elixir: "~> 1.14",
      description: "The CLI for Jet Team.",
      source_url: "https://github.com/Byzanteam/jet_cli",
      package: [
        name: "jet_cli",
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/Byzanteam/jet_cli"
        }
      ],
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      dialyzer: [
        plt_apps: [:mix]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
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
