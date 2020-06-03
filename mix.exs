defmodule LcovEx.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :lcov_ex,
      description: "Lcov file generator.",
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: LcovEx],
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
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

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
