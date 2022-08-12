defmodule EvalEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :evalex,
      version: "0.1.0-alpha",
      elixir: "~> 1.11",
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
      {:rustler, "~> 0.25.0"},
      {:rustler_precompiled, "~> 0.5.1"}
    ]
  end
end
