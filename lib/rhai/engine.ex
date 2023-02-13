defmodule Rhai.Engine do
  @moduledoc """
  Rhai main scripting engine.
  """

  alias Rhai.AST

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
  Evaluate a string as a script, returning the result value or an error.
  """
  @spec eval(t(), String.t()) :: {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def eval(%__MODULE__{resource: resource}, script) do
    Rhai.Native.engine_eval(resource, script)
  end

  @doc """
  Evaluate a string as a script with own scope, returning the result value or an error.
  """
  @spec eval_with_scope(t(), Rhai.Scope.t(), String.t()) ::
          {:ok, Rhai.rhai_any()} | {:error, Rhai.rhai_error()}
  def eval_with_scope(
        %__MODULE__{resource: engine_resource},
        %Rhai.Scope{resource: scope_resource},
        script
      ) do
    Rhai.Native.engine_eval_with_scope(engine_resource, scope_resource, script)
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

  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end
end
