defmodule EvalEx.MixProject do
  use Mix.Project

  @version "0.1.0-alpha"

  def project do
    [
      app: :evalex,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "A powerful expression evaluation library for Elixir, based on the Rust crate evalexpr.",
      package: [
        files: [
          "lib",
          "native",
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
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.25.0"},
      {:rustler_precompiled, "~> 0.5.1"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
