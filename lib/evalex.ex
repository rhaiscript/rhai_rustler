defmodule EvalEx do
  @moduledoc """
  EvalEx is a powerful expression evaluation library for Elixir,
  based on [evalexpr](https://github.com/ISibboI/evalexpr) using [rustler](https://github.com/rusterlium/rustler).
  """

  @type evalex_any :: number() | boolean() | String.t() | nil | [evalex_any()]

  @type evalex_error ::
          :wrong_operator_amount
          | :wrong_function_argument_amount
          | :expected_string
          | :expected_int
          | :expected_float
          | :expected_number
          | :expected_number_or_string
          | :expected_boolean
          | :expected_tuple
          | :exepcted_fixed_length_tuple
          | :expected_empty
          | :append_to_leaf_node
          | :precedence_violation
          | :variable_identifier_not_found
          | :function_identefier_not_found
          | :type_error
          | :wrong_type_combination
          | :unmatched_l_brace
          | :unmatched_r_brace
          | :missing_operator_outside_of_brace
          | :unmatched_partial_token
          | :addition_error
          | :subtraction_error
          | :negation_error
          | :multiplication_error
          | :division_error
          | :modulation_error
          | :invaild_regex
          | :context_not_mutable
          | :illegal_escape_sequence
          | :custom_message
          | :unknown

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

      iex> {:ok, precompiled_expression} = EvalEx.precompile_expression("1 + 1")
      {:ok,
      %EvalEx.PrecompiledExpression{
      reference: #Reference<0.2278913865.304611331.189837>,
      resource: #Reference<0.2278913865.304742403.189834>
      }}

      iex> EvalEx.eval(precompiled_expression)
      {:ok, 2}
  """
  @doc since: "0.1.0"
  @spec eval(String.t() | EvalEx.PrecompiledExpression.t(), map()) ::
          {:ok, evalex_any()} | {:error, {evalex_error(), String.t()}}
  def eval(expression, context \\ %{})

  def eval(%EvalEx.PrecompiledExpression{resource: resource}, %{} = context),
    do: EvalEx.Native.eval_precompiled_expression(resource, context)

  def eval(expression, context) when is_binary(expression),
    do: EvalEx.Native.eval(expression, %{} = context)

  @doc """
  Precompiles the given expression.
  """
  @doc since: "0.1.1"
  @spec precompile_expression(String.t()) ::
          {:ok, EvalEx.PrecompiledExpression.t()} | {:error, {evalex_error(), String.t()}}
  def precompile_expression(expression) do
    case EvalEx.Native.precompile_expression(expression) do
      {:ok, resource} ->
        {:ok, EvalEx.PrecompiledExpression.wrap_resource(resource)}

      {:error, error} ->
        {:error, error}
    end
  end
end
