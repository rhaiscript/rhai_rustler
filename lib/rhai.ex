defmodule Rhai do
  @moduledoc """
  Rhai elixir bindings

  """
  @doc """
  Evaluates the given expression and returns the result.

  ## Examples

      iex> Rhai.eval("1 + 1")
      {:ok, 2}

      iex> Rhai.eval("a * b", %{"a" => 10, "b" => 10})
      {:ok, 100}

      iex> Rhai.eval("a == b", %{"a" => "tonio", "b" => "wanda"})
      {:ok, false}

      iex> Rhai.eval("a != b", %{"a" => "tonio", "b" => "wanda"})
      {:ok, true}

      iex> Rhai.eval("a.len()", %{"a" => [1, 2, 3]})
      {:ok, 3}

      iex> Rhai.eval("a.filter(|v| v > 3)", %{"a" => [1, 2, 3, 5, 8, 13]})
      {:ok, [5, 8, 13]}

      iex> Rhai.eval("a.b", %{"a" => %{"b" => 1}})
      {:ok, 1}

      iex> Rhai.eval("a + b", %{"a" => 10})
      {:error, {:variable_not_found, "Variable not found: b (line 1, position 5)"}}
  """
  @doc since: "0.1.0"
  @deprecated "Use Rhai.Engine instead"
  @spec eval(String.t() | Rhai.PrecompiledExpression.t(), map()) ::
          {:ok, Rhai.Any.t()} | {:error, {Rhai.Error.t(), String.t()}}
  def eval(expression, context \\ %{}) do
    Rhai.Native.eval(expression, %{} = context)
  end
end
