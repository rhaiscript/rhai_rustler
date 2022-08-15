defmodule EvalEx.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :evalex,
      version: @version,
      elixir: "~> 1.11",
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
    "A powerful expression evaluation library for Elixir, based on evalexpr using rustler."
  end

  defp package do
    [
      files: [
        "lib",
        "native/evalex/.cargo",
        "native/evalex/src",
        "native/evalex/Cargo*",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      licenses: ["Apache-2.0"],
      mantainers: ["Fabrizio Sestito <fabrizio.sestito@suse.com>"],
      links: %{
        "GitHub" => "https://github.com/fabriziosestito/evalex",
        "Docs" => "https://hexdocs.pm/evalex/"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.25.0"},
      {:rustler_precompiled, "~> 0.5.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
