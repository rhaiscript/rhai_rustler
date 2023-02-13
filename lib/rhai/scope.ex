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

  @spec push_dynamic(t(), String.t(), Rhai.rhai_any()) :: t()
  def push_dynamic(%__MODULE__{resource: resource} = scope, name, value) do
    Rhai.Native.scope_push_dynamic(resource, name, value)

    scope
  end

  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end
end
