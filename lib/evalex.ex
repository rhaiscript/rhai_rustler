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
  """
  @doc since: "0.1.0"
  @spec eval(String.t(), map()) :: {:ok, evalex_any()} | {:error, {evalex_error(), String.t()}}
  def eval(expression, %{} = context \\ %{}), do: EvalEx.Native.eval(expression, context)
end
