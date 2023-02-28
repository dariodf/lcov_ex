defmodule LcovEx.MixProject do
  use Mix.Project

  @version "0.3.1"

  def project do
    [
      app: :lcov_ex,
      description: "Lcov file generator.",
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :tools]
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      source_url: "https://github.com/dariodf/lcov_ex",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      files: ~w(lib test mix.exs README.md LICENSE),
      maintainers: ["dariodf"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dariodf/lcov_ex"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end
