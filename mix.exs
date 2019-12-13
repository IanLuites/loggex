defmodule Loggex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :loggex,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Logging utilities for Elixir.",
      docs: docs()
    ]
  end

  defp docs do
    [
      main: "Loggex",
      canonical: "http://hexdocs.pm/loggex",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      source_url: "https://github.com/IanLuites/loggex",
      groups_for_modules: [
        Adapters: [
          Loggex.Adapters.Console,
          Loggex.Adapters.Fluentd,
          Loggex.Adapters.Kafka,
          Loggex.Adapters.Logstash,
          Loggex.Adapters.Test,
          Loggex.Adapters.Webhook
        ]
      ]
    ]
  end

  defp package do
    [
      name: :loggex,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: ~W(.formatter.exs mix.exs README.md LICENSE lib),
      links: %{}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.1"},
      {:httpx, "~> 0.0.16"},
      {:msgpack, "~> 0.7.0"},

      # Dev
      {:analyze, ">= 0.1.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}
    ]
  end
end
