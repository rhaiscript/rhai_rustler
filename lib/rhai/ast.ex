defmodule Rhai.AST do
  @moduledoc """
  Compiled AST (abstract syntax tree) of a Rhai script.
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
  Create an empty AST.
  """
  def empty() do
    resource = Rhai.Native.ast_empty()

    wrap_resource(resource)
  end

  @doc """
  Get the source if any.
  """
  @spec source(t) :: String.t() | nil
  def source(%__MODULE__{resource: resource}) do
    Rhai.Native.ast_source(resource)
  end

  @doc """
  Set the source.
  """
  @spec set_source(t, String.t()) :: t
  def set_source(%__MODULE__{resource: resource} = ast, source) do
    Rhai.Native.ast_set_source(resource, source)

    ast
  end

  @doc """
  Clear the source.
  """
  @spec clear_source(t) :: t
  def clear_source(%__MODULE__{resource: resource} = ast) do
    Rhai.Native.ast_clear_source(resource)

    ast
  end

  @doc false
  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end
end
