defmodule EvalEx do
  @moduledoc """
  EvalEx is a powerful expression evaluation library for Elixir,
  based on [evalexpr](https://github.com/ISibboI/evalexpr) using [rustler](https://github.com/rusterlium/rustler).
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

  ## Examples

      iex> EvalEx.eval("1 + 1")
      {:ok, 2}

      iex> EvalEx.eval("a * b", %{"a" => 10, "b" => 10})
      {:ok, 100}

      iex> EvalEx.eval("a == b", %{"a" => "tonio", "b" => "wanda"})
      {:ok, false}

      iex> EvalEx.eval("a != b", %{"a" => "tonio", "b" => "wanda"})
      {:ok, true}

      iex> EvalEx.eval("len(a)", %{"a" => [1, 2, 3]})
      {:ok, 3}

      iex> EvalEx.eval("a + b", %{"a" => 10})
      {:error,
      {:variable_identifier_not_found,
      "Variable identifier is not bound to anything by context: \"b\"."}}
  """
  @doc since: "0.1.0"
  @spec eval(String.t(), map()) :: {:ok, evalex_any()} | {:error, {atom(), String.t()}}
  def eval(_, _) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
