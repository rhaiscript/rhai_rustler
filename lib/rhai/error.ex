defmodule Rhai.Error do
  @moduledoc false

  @type error ::
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
          | :non_pure_method_call_on_constant
          | :scope_is_empty
          | :cannot_update_value_of_constant
          | :custom_operator

  @type t() :: {error(), String.t()}
end
