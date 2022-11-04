defmodule Rhai do
  @moduledoc """
  Rhai elixir bindings
  """

  @type rhai_any ::
          number() | boolean() | String.t() | nil | [rhai_any()] | %{String.t() => rhai_any()}

  @type rhai_error ::
          :system
          | :parsing
          | :variable_exists
          | :forbidden_variable
          | :variable_not_found
          | :property_not_found
          | :index_not_found
          | :function_not_found
          | :module_not_found
          | :in_function_call
          | :in_module
          | :unbound_this
          | :mismatch_data_type
          | :mismatch_output_type
          | :indexing_type
          | :array_bounds
          | :string_bounds
          | :bit_field_bounds
          | :for_atom
          | :data_race
          | :assignment_to_constant
          | :dot_expr
          | :arithmetic
          | :too_many_operations
          | :too_many_modules
          | :stack_overflow
          | :data_too_large
          | :terminated
          | :custom_syntax
          | :runtime

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
  @spec eval(String.t() | Rhai.PrecompiledExpression.t(), map()) ::
          {:ok, rhai_any()} | {:error, {rhai_error(), String.t()}}
  def eval(expression, context \\ %{}) do
    Rhai.Native.eval(expression, %{} = context)
  end
end
