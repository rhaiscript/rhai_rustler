defmodule EvalEx do
  @moduledoc """
  EvalEx is a powerful expression evaluation library for Elixir,
  based on [evalexpr](https://github.com/ISibboI/evalexpr) using [rustler](https://github.com/rusterlium/rustler).
  """

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
  def eval(expression, context \\ %{}), do: EvalEx.Native.eval(expression, context)
end
