defmodule Supermarket.MixProject do
  use Mix.Project

  def project do
    [
      app: :supermarket,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      source_url: "https://github.com/satom99/supermarket"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Supermarket.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:decimal, "~> 2.1"},
      {:money, "~> 1.12"},
      {:patch, "~> 0.12.0", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:faker, "~> 0.17", only: :test},
      {:excoveralls, "~> 0.16.1", only: :test},
      {:credo, "~> 1.7", only: :dev},
      {:ex_doc, "~> 0.29.4", only: :dev}
    ]
  end

  defp docs() do
    [
      groups_for_modules: [
        Product: Supermarket.Product,
        Basket: ~r/^Supermarket.Basket.?/,
        Pricing: ~r/^Supermarket.Pricing.?/
      ]
    ]
  end
end
