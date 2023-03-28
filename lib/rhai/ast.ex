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
  def empty do
    resource = Rhai.Native.ast_empty()

    wrap_resource(resource)
  end

  @doc """
  Get the source if any.
  """
  @spec source(t()) :: String.t() | nil
  def source(%__MODULE__{resource: resource}) do
    Rhai.Native.ast_source(resource)
  end

  @doc """
  Set the source.
  """
  @spec set_source(t(), String.t()) :: t()
  def set_source(%__MODULE__{resource: resource} = ast, source) do
    Rhai.Native.ast_set_source(resource, source)

    ast
  end

  @doc """
  Clear the source.
  """
  @spec clear_source(t()) :: t()
  def clear_source(%__MODULE__{resource: resource} = ast) do
    Rhai.Native.ast_clear_source(resource)

    ast
  end

  @doc """
  Merge two AST into one. Both AST’s are untouched and a new, merged, version is returned.

  Statements in the second AST are simply appended to the end of the first without any processing. 
  Thus, the return value of the first AST (if using expression-statement syntax) is buried.
  Of course, if the first AST uses a return statement at the end, then the second AST will essentially be dead code.

  All script-defined functions in the second AST overwrite similarly-named functions in the first AST with the same number of parameters.

  See [example](https://docs.rs/rhai/latest/rhai/struct.AST.html#example-1) in the Rhai documentation. 
  """
  @spec merge(t(), t()) :: t()
  def merge(
        %__MODULE__{resource: resource},
        %__MODULE__{resource: other_resource}
      ) do
    resource
    |> Rhai.Native.ast_merge(other_resource)
    |> wrap_resource()
  end

  @doc """
  Combine one AST with another. The second AST is consumed.

  Statements in the second AST are simply appended to the end of the first without any processing.
  Thus, the return value of the first AST (if using expression-statement syntax) is buried.
  Of course, if the first AST uses a return statement at the end, then the second AST will essentially be dead code.

  All script-defined functions in the second AST overwrite similarly-named functions in the first AST with the same number of parameters.

  See [example](https://docs.rs/rhai/latest/rhai/struct.AST.html#example-2) in the Rhai documentation. 
  """
  @spec combine(t(), t()) :: t()
  def combine(
        %__MODULE__{resource: resource},
        %__MODULE__{resource: other_resource}
      ) do
    resource
    |> Rhai.Native.ast_combine(other_resource)
    |> wrap_resource()
  end

  @doc """
  Clear all function definitions in the AST.
  """
  @spec clear_functions(t()) :: t()
  def clear_functions(%__MODULE__{resource: resource} = ast) do
    Rhai.Native.ast_clear_functions(resource)

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
