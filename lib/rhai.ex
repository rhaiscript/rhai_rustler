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

      iex> Rhai.eval("len(a)", %{"a" => [1, 2, 3]})
      {:ok, 3}

      iex> Rhai.eval("a + b", %{"a" => 10})
      {:error,
      {:variable_identifier_not_found,
      "Variable identifier is not bound to anything by context: \"b\"."}}

      iex> {:ok, precompiled_expression} = Rhai.precompile_expression("1 + 1")
      {:ok,
      %Rhai.PrecompiledExpression{
      reference: #Reference<0.2278913865.304611331.189837>,
      resource: #Reference<0.2278913865.304742403.189834>
      }}

      iex> Rhai.eval(precompiled_expression)
      {:ok, 2}
  """
  @doc since: "0.1.0"
  @spec eval(String.t() | Rhai.PrecompiledExpression.t(), map()) ::
          {:ok, rhai_any()} | {:error, {rhai_error(), String.t()}}
  def eval(expression, context \\ %{})

  def eval(%Rhai.PrecompiledExpression{resource: resource}, %{} = context),
    do: Rhai.Native.eval_precompiled_expression(resource, context)

  def eval(expression, context) when is_binary(expression),
    do: Rhai.Native.eval(expression, %{} = context)

  @doc """
  Precompiles the given expression.
  """
  @doc since: "0.1.0"
  @spec precompile_expression(String.t()) ::
          {:ok, Rhai.PrecompiledExpression.t()} | {:error, {rhai_error(), String.t()}}
  def precompile_expression(expression) do
    case Rhai.Native.precompile_expression(expression) do
      {:ok, resource} ->
        {:ok, Rhai.PrecompiledExpression.wrap_resource(resource)}

      {:error, error} ->
        {:error, error}
    end
  end
end
