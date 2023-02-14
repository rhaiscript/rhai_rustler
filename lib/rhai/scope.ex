defmodule Rhai.Scope do
  @moduledoc """
  Type containing information about the current scope. Useful for keeping state between Engine evaluation runs.
  """

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
  Create a new Scope
  """
  @spec new :: t()
  def new do
    wrap_resource(Rhai.Native.scope_new())
  end

  @doc """
  Add (push) a new Dynamic entry to the Scope.
  """
  @spec push_dynamic(t(), String.t(), Rhai.rhai_any()) :: t()
  def push_dynamic(%__MODULE__{resource: resource} = scope, name, value) do
    Rhai.Native.scope_push_dynamic(resource, name, value)

    scope
  end

  @doc """
  Add (push) a new constant with a Dynamic value to the Scope.

  Constants are immutable and cannot be assigned to. Their values never change.
  Constants propagation is a technique used to optimize an AST.
  """
  @spec push_constant_dynamic(t(), String.t(), Rhai.rhai_any()) :: t()
  def push_constant_dynamic(%__MODULE__{resource: resource} = scope, name, value) do
    Rhai.Native.scope_push_constant_dynamic(resource, name, value)

    scope
  end

  @doc """
  Does the Scope contain the entry?
  """
  @spec contains?(t(), String.t()) :: bool()
  def contains?(%__MODULE__{resource: resource}, name) do
    Rhai.Native.scope_contains(resource, name)
  end

  @doc """
  Does the Scope contain the entry?
  """
  @spec is_constant(t(), String.t()) :: nil | bool()
  def is_constant(%__MODULE__{resource: resource}, name) do
    Rhai.Native.scope_is_constant(resource, name)
  end

  @doc """
  Get a reference to an entry in the Scope.

  If the entry by the specified name is not found, nil is returned.
  """
  @spec get(t(), String.t()) :: nil | Rhai.rhai_any()
  def get(%__MODULE__{resource: resource}, name) do
    Rhai.Native.scope_get(resource, name)
  end

  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end
end
