defmodule Rhai.Engine do
  @moduledoc """
  Rhai main scripting engine.
  """

  alias Rhai.{AST, Scope}

  defstruct [
    # The actual NIF Resource.
    resource: nil,
    # Normally the compiler will happily do stuff like inlining the
    # resource in attributes. This will convert the resource into an
    # empty binary with no warning. This will make that harder to
    # accidentaly do.
    # It also serves as a handy way to tell file handles apart.
    reference: nil
  ]

  @type t :: %__MODULE__{}

  @doc """
  Create a new Engine
  """
  @spec new :: t()
  def new do
    wrap_resource(Rhai.Native.engine_new())
  end

  @doc """
  Register a shared dylib Module into the global namespace of Engine.

  All functions and type iterators are automatically available to scripts without namespace qualifications.
  Sub-modules and variables are ignored.
  When searching for functions, modules loaded later are preferred. In other words, loaded modules are searched in reverse order.

  Returns an error if the module cannot be loaded. 
  """
  @spec register_global_module(t(), String.t()) ::
          {:ok, t()} | {:error, {:runtime, String.t()}}
  def register_global_module(%__MODULE__{resource: resource} = engine, path) do
    with {:ok, _} <- Rhai.Native.engine_register_global_module(resource, path) do
      {:ok, engine}
    end
  end

  @doc """
  Register a shared dylib Module into the global namespace of Engine.

  All functions and type iterators are automatically available to scripts without namespace qualifications.
  Sub-modules and variables are ignored.
  When searching for functions, modules loaded later are preferred. In other words, loaded modules are searched in reverse order.

  Raises an error if the module cannot be loaded.
  """
  @spec register_global_module!(t(), String.t()) :: t()
  def register_global_module!(%__MODULE__{} = engine, path) do
    case register_global_module(engine, path) do
      {:ok, _} ->
        engine

      {:error, {:runtime, message}} ->
        raise message
    end
  end

  @doc """
  Register a shared Module into the namespace of Engine.
    
  Returns an error if the module cannot be loaded. 
  """
  @spec register_static_module(t(), String.t(), String.t()) ::
          {:ok, t()} | {:error, {:runtime, String.t()}}
  def register_static_module(%__MODULE__{resource: resource} = engine, namespace, path) do
    with {:ok, _} <-
           Rhai.Native.engine_register_static_module(resource, namespace, path) do
      {:ok, engine}
    end
  end

  @doc """
  Register a shared Module into the namespace of Engine.

  Raises an error if the module cannot be loaded.
  """
  @spec register_static_module!(t(), String.t(), String.t()) :: t()
  def register_static_module!(%__MODULE__{} = engine, namespace, path) do
    case register_static_module(engine, namespace, path) do
      {:ok, _} ->
        engine

      {:error, {:runtime, message}} ->
        raise message
    end
  end

  @doc """
  Compile a string into an AST, which can be used later for evaluation.
  """
  @spec compile(t(), String.t()) :: {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def compile(%__MODULE__{resource: resource}, script) do
    resource
    |> Rhai.Native.engine_compile(script)
    |> case do
      {:ok, ast} -> {:ok, AST.wrap_resource(ast)}
      error -> error
    end
  end

  @doc """
  Compact a script to eliminate insignificant whitespaces and comments.
  This is useful to prepare a script for further compressing.
  The output script is semantically identical to the input script, except smaller in size.
  Unlike other uglifiers and minifiers, this method does not rename variables nor perform any optimization on the input script.
  """
  @spec compact_script(t(), String.t()) :: String.t()
  def compact_script(%__MODULE__{resource: resource}, script) do
    Rhai.Native.engine_compact_script(resource, script)
  end

  @doc """
  Evaluate a string as a script, returning the result value or an error.
  """
  @spec eval(t(), String.t()) :: {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def eval(%__MODULE__{resource: resource}, script) do
    Rhai.Native.engine_eval(resource, script)
  end

  @doc """
  Evaluate a string as a script with own scope, returning the result value or an error.
  """
  @spec eval_with_scope(t(), Scope.t(), String.t()) ::
          {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def eval_with_scope(
        %__MODULE__{resource: engine_resource},
        %Scope{resource: scope_resource},
        script
      ) do
    Rhai.Native.engine_eval_with_scope(engine_resource, scope_resource, script)
  end

  @doc """
  Evaluate an AST, returning the result value or an error.
  """
  @spec eval_ast(t(), AST.t()) :: {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def eval_ast(%__MODULE__{resource: resource}, %AST{resource: ast_resource}) do
    Rhai.Native.engine_eval_ast(resource, ast_resource)
  end

  @doc """
  Evaluate a string as script.
  """
  @spec run(t(), String.t()) :: :ok | {:error, Rhai.rhai_error()}
  def run(%__MODULE__{resource: resource}, script) do
    case Rhai.Native.engine_run(resource, script) do
      {:ok, _} ->
        :ok

      error ->
        error
    end
  end

  @doc """
  Evaluate a string as script with own scope.
  """
  @spec run_with_scope(t(), Scope.t(), String.t()) :: :ok | {:error, Rhai.rhai_error()}
  def run_with_scope(
        %__MODULE__{resource: engine_resource},
        %Scope{resource: scope_resource},
        script
      ) do
    case Rhai.Native.engine_run_with_scope(engine_resource, scope_resource, script) do
      {:ok, _} ->
        :ok

      error ->
        error
    end
  end

  @doc """
  Call a script function defined in an AST with multiple arguments.
  """
  @spec call_fn(t(), Scope.t(), AST.t(), String.t(), list()) ::
          {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def call_fn(
        %__MODULE__{resource: resource},
        %Scope{resource: scope_resource},
        %AST{resource: ast_resource},
        name,
        args
      ) do
    Rhai.Native.engine_call_fn(resource, scope_resource, ast_resource, name, args)
  end

  @doc """
  Set the maximum length of arrays (0 for unlimited).

  Not available under `unchecked` or `no_index`.
  """
  @spec set_max_array_size(t(), integer()) :: t()
  def set_max_array_size(%__MODULE__{resource: resource} = engine, max_size) do
    Rhai.Native.engine_set_max_array_size(resource, max_size)

    engine
  end

  @doc """
  The maximum length of arrays (0 for unlimited).

  Zero under `no_index`.
  """
  @spec max_array_size(t()) :: integer()
  def max_array_size(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_array_size(resource)
  end

  @doc """
  Set whether to raise error if an object map property does not exist.
  """
  @spec set_fail_on_invalid_map_property(t(), boolean) :: t()
  def set_fail_on_invalid_map_property(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_fail_on_invalid_map_property(resource, enable)

    engine
  end

  @doc """
  Set whether to raise error if an object map property does not exist.
  """
  @spec fail_on_invalid_map_property?(t()) :: boolean
  def fail_on_invalid_map_property?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_fail_on_invalid_map_property(resource)
  end

  @doc """
  Set whether anonymous function is allowed.

  Not available under `no_function`.
  """
  @spec set_allow_anonymous_fn(t(), boolean) :: t()
  def set_allow_anonymous_fn(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_anonymous_fn(resource, enable)

    engine
  end

  @doc """
  Is anonymous function allowed? Default is true.

  Not available under `no_function`.
  """
  @spec allow_anonymous_fn?(t()) :: boolean
  def allow_anonymous_fn?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_anonymous_fn(resource)
  end

  @doc """
  Set whether `if`-expression is allowed.
  """
  @spec set_allow_if_expression(t(), boolean) :: t()
  def set_allow_if_expression(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_if_expression(resource, enable)

    engine
  end

  @doc """
  Is if-expression allowed? Default is `true`.
  """
  @spec allow_if_expression?(t()) :: boolean
  def allow_if_expression?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_if_expression(resource)
  end

  @doc """
  Set whether loop expressions are allowed.
  """
  @spec set_allow_loop_expressions(t(), boolean) :: t()
  def set_allow_loop_expressions(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_loop_expressions(resource, enable)

    engine
  end

  @doc """
  Are loop-expression allowed? Default is `true`.
  """
  @spec allow_loop_expressions?(t()) :: boolean
  def allow_loop_expressions?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_loop_expressions(resource)
  end

  @doc """
  Set whether looping is allowed.
  """
  @spec set_allow_looping(t(), boolean) :: t()
  def set_allow_looping(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_looping(resource, enable)

    engine
  end

  @doc """
  Is looping allowed? Default is `true`.
  """
  @spec allow_looping?(t()) :: boolean
  def allow_looping?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_looping(resource)
  end

  @doc """
  Set whether shadowing is allowed.
  """
  @spec set_allow_shadowing(t(), boolean) :: t()
  def set_allow_shadowing(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_shadowing(resource, enable)

    engine
  end

  @doc """
  Is shadowing allowed? Default is `true`.
  """
  @spec allow_shadowing?(t()) :: boolean
  def allow_shadowing?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_shadowing(resource)
  end

  @doc """
  Set whether statement_expression is allowed.
  """
  @spec set_allow_statement_expression(t(), boolean) :: t()
  def set_allow_statement_expression(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_statement_expression(resource, enable)

    engine
  end

  @doc """
  Is statement_expression allowed? Default is `true`.
  """
  @spec allow_statement_expression?(t()) :: boolean
  def allow_statement_expression?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_statement_expression(resource)
  end

  @doc """
  Set whether `switch` expression is allowed.
  """
  @spec set_allow_switch_expression(t(), boolean) :: t()
  def set_allow_switch_expression(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_allow_switch_expression(resource, enable)

    engine
  end

  @doc """
  Is `switch` expression allowed? Default is `true`.
  """
  @spec allow_switch_expression?(t()) :: boolean
  def allow_switch_expression?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_allow_switch_expression(resource)
  end

  @doc """
  Set whether fast operators mode is enabled.
  """
  @spec set_fast_operators(t(), boolean) :: t()
  def set_fast_operators(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_fast_operators(resource, enable)

    engine
  end

  @doc """
  Is fast operators mode enabled? Default is `false`.
  """
  @spec fast_operators?(t()) :: boolean
  def fast_operators?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_fast_operators(resource)
  end

  @doc """
  Set the maximum levels of function calls allowed for a script in order to avoid infinite recursion and stack overflows.

  Not available under `unchecked` or `no_function`.
  """
  @spec set_max_call_levels(t(), non_neg_integer()) :: t()
  def set_max_call_levels(%__MODULE__{resource: resource} = engine, levels) do
    Rhai.Native.engine_set_max_call_levels(resource, levels)

    engine
  end

  @doc """
  Is fast operators mode enabled? Default is `false`.
  """
  @spec max_call_levels(t()) :: non_neg_integer()
  def max_call_levels(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_call_levels(resource)
  end

  @doc """
  Set the depth limits for expressions (0 for unlimited).

  Not available under `unchecked`.
  """
  @spec set_max_expr_depths(t(), non_neg_integer(), non_neg_integer()) :: t()
  def set_max_expr_depths(
        %__MODULE__{resource: resource} = engine,
        max_expr_depth,
        max_function_expr_depth
      ) do
    Rhai.Native.engine_set_max_expr_depths(resource, max_expr_depth, max_function_expr_depth)

    engine
  end

  @doc """
  The depth limit for expressions (0 for unlimited).
  """
  @spec max_expr_depth(t()) :: non_neg_integer()
  def max_expr_depth(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_expr_depth(resource)
  end

  @doc """
  The depth limit for expressions in functions (0 for unlimited).

  Zero under `no_function`.
  """
  @spec max_function_expr_depth(t()) :: non_neg_integer()
  def max_function_expr_depth(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_function_expr_depth(resource)
  end

  @doc """
  Set the maximum size of object maps (0 for unlimited).

  Not available under `unchecked` or `no_object`.
  """
  @spec set_max_map_size(t(), non_neg_integer()) :: t()
  def set_max_map_size(%__MODULE__{resource: resource} = engine, size) do
    Rhai.Native.engine_set_max_map_size(resource, size)

    engine
  end

  @doc """
  The maximum size of object maps (0 for unlimited).

  Zero under `no_object`.
  """
  @spec max_map_size(t()) :: non_neg_integer()
  def max_map_size(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_map_size(resource)
  end

  @doc """
  Set the maximum number of imported modules allowed for a script.

  Not available under `unchecked` or `no_module`.
  """
  @spec set_max_modules(t(), non_neg_integer()) :: t()
  def set_max_modules(%__MODULE__{resource: resource} = engine, modules) do
    Rhai.Native.engine_set_max_modules(resource, modules)

    engine
  end

  @doc """
  The maximum number of imported modules allowed for a script.

  Zero under `no_module`.
  """
  @spec max_modules(t()) :: non_neg_integer()
  def max_modules(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_modules(resource)
  end

  @doc """
  Set the maximum number of operations allowed for a script to run to avoid consuming too much resources (0 for unlimited).

  Not available under `unchecked`.
  """
  @spec set_max_operations(t(), non_neg_integer()) :: t()
  def set_max_operations(%__MODULE__{resource: resource} = engine, operations) do
    Rhai.Native.engine_set_max_operations(resource, operations)

    engine
  end

  @doc """
  The maximum number of operations allowed for a script to run (0 for unlimited).

  Not available under `unchecked`.
  """
  @spec max_operations(t()) :: non_neg_integer()
  def max_operations(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_operations(resource)
  end

  @doc """
  Set the maximum length, in bytes, of strings (0 for unlimited).

  Not available under `unchecked`.
  """
  @spec set_max_string_size(t(), non_neg_integer()) :: t()
  def set_max_string_size(%__MODULE__{resource: resource} = engine, string_size) do
    Rhai.Native.engine_set_max_string_size(resource, string_size)

    engine
  end

  @doc """
  The maximum length, in bytes, of strings (0 for unlimited).
  """
  @spec max_string_size(t()) :: non_neg_integer()
  def max_string_size(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_max_string_size(resource)
  end

  @doc """
  Set whether strict variables mode is enabled.
  """
  @spec set_strict_variables(t(), boolean) :: t()
  def set_strict_variables(%__MODULE__{resource: resource} = engine, enable) do
    Rhai.Native.engine_set_strict_variables(resource, enable)

    engine
  end

  @doc """
  Is strict variables mode enabled? Default is `false`.
  """
  @spec strict_variables?(t()) :: boolean
  def strict_variables?(%__MODULE__{resource: resource}) do
    Rhai.Native.engine_strict_variables(resource)
  end

  @doc false
  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end
end
