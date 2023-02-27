defmodule ExampleProject.MixProject do
  use Mix.Project

  def project do
    [
      app: :example_failing_project,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: ["lib"],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:lcov_ex, path: "../", only: [:dev, :test]}
    ]
  end
end
