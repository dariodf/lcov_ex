defmodule ExampleProject.MixProject do
  use Mix.Project

  def project do
    [
      app: :example_project,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:lcov_ex, path: "../", only: [:dev, :test]},
      {:mox, path: "../deps/mox", only: [:dev, :test]}
    ]
  end
end
