defmodule EvalEx do
  @moduledoc """
  EvalEx is an expression evaluator and tiny scripting language for elixir,
  powered by the Rust crate evalexpr.
"""

  version = Mix.Project.config()[:version]

  targets = ~w(
    aarch64-apple-darwin
    x86_64-apple-darwin
    x86_64-unknown-linux-gnu
    x86_64-unknown-linux-musl
    arm-unknown-linux-gnueabihf
    aarch64-unknown-linux-gnu
    aarch64-unknown-linux-musl
    x86_64-pc-windows-msvc
    x86_64-pc-windows-gnu
  )

  use RustlerPrecompiled,
    otp_app: :evalex,
    crate: "evalex",
    base_url: "https://github.com/fabriziosestito/evalex/releases/download/v#{version}",
    force_build: System.get_env("EVALEX_FORCE_BUILD") == "true",
    version: version,
    targets: targets

  @type evalex_any :: number() | boolean() | String.t() | nil | [evalex_any()]

  @doc """
  Evaluates the given expression and returns the result.
  """
  @doc since: "0.1.0"
  @spec eval(String.t(), map()) :: {:ok, evalex_any()} | {:error, {atom(), String.t()}}
  def eval(_, _) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
