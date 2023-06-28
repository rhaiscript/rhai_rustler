defmodule Rhai.MixProject do
  use Mix.Project

  @version "1.1.0-dev"

  def project do
    [
      app: :rhai_rustler,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Rhai rustler bindings"
  end

  defp package do
    [
      files: [
        "lib",
        "native/rhai_rustler/.cargo",
        "native/rhai_rustler/src",
        "native/rhai_rustler/Cargo*",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "guides/nif-bindings.md",
        "LICENSE"
      ],
      licenses: ["Apache-2.0"],
      mantainers: ["Fabrizio Sestito <fabrizio.sestito@suse.com>"],
      links: %{
        "GitHub" => "https://github.com/fabriziosestito/rhai_rustler",
        "Docs" => "https://hexdocs.pm/rhai_rustler/"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "guides/nif-bindings.md", "LICENSE"]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test),
    do: [
      "lib",
      "test/support"
    ]

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:rustler, "~> 0.29.0"},
      {:rustler_precompiled, "~> 0.6.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.5", only: [:dev, :test]},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false}
    ]
  end
end
