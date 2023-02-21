defmodule Rhai.Scope do
  @moduledoc """
  Type containing information about the current scope. Useful for keeping state between Engine evaluation runs.
  Scope implements the [https://hexdocs.pm/elixir/1.12/Enumerable.html](Enumerable) protocol.
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
  Create a new Scope with a particular capacity.
  """
  @spec with_capacity(non_neg_integer()) :: t()
  def with_capacity(capacity) do
    capacity
    |> Rhai.Native.scope_with_capacity()
    |> wrap_resource()
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
  Check if the named entry in the Scope is constant.
  Search starts backwards from the last, stopping at the first entry matching the specified name.
  Returns nil if no entry matching the specified name is found.
  """
  @spec is_constant(t(), String.t()) :: nil | bool()
  def is_constant(%__MODULE__{resource: resource}, name) do
    Rhai.Native.scope_is_constant(resource, name)
  end

  @doc """
  Get the value of an entry in the Scope, starting from the last.
  """
  @spec get_value(t(), String.t()) :: nil | Rhai.rhai_any()
  def get_value(%__MODULE__{resource: resource}, name) do
    Rhai.Native.scope_get_value(resource, name)
  end

  @doc """
  Empty the Scope.
  """
  @spec clear(t()) :: t()
  def clear(%__MODULE__{resource: resource} = scope) do
    Rhai.Native.scope_clear(resource)

    scope
  end

  @doc """
  Clone the Scope, keeping only the last instances of each variable name. Shadowed variables are omitted in the copy.
  """
  @spec clone_visible(t()) :: t()
  def clone_visible(%__MODULE__{resource: resource}) do
    resource
    |> Rhai.Native.scope_clone_visible()
    |> wrap_resource()
  end

  @doc """
  Returns true if this Scope contains no variables.
  """
  @spec is_empty(t()) :: bool()
  def is_empty(%__MODULE__{resource: resource}) do
    Rhai.Native.scope_is_empty(resource)
  end

  @doc """
  Get the number of entries inside the Scope.
  """
  @spec len(t()) :: non_neg_integer()
  def len(%__MODULE__{resource: resource}) do
    Rhai.Native.scope_len(resource)
  end

  @doc """
  Remove the last entry in the Scope by the specified name and return its value.

  If the entry by the specified name is not found, None is returned.
  """
  @spec remove(t(), String.t()) :: nil | Rhai.rhai_any()
  def remove(%__MODULE__{resource: resource}, name) do
    Rhai.Native.scope_remove(resource, name)
  end

  @doc """
  Truncate (rewind) the Scope to a previous size.
  """
  @spec rewind(t(), non_neg_integer()) :: t()
  def rewind(%__MODULE__{resource: resource} = scope, size) do
    Rhai.Native.scope_rewind(resource, size)

    scope
  end

  @doc """
  Remove the last entry from the Scope.

  Returns an error if the Scope is empty.
  """
  @spec pop(t()) :: {:ok, t()} | {:error, {:scope_is_empty, String.t()}}
  def pop(%__MODULE__{resource: resource} = scope) do
    case Rhai.Native.scope_pop(resource) do
      {:ok, _} ->
        {:ok, scope}

      error ->
        error
    end
  end

  @doc """
  Remove the last entry from the Scope.

  Raises if the Scope is empty.
  """
  @spec pop!(t()) :: t()
  def pop!(%__MODULE__{} = scope) do
    case pop(scope) do
      {:ok, _} ->
        scope

      {:error, {:scope_is_empty, message}} ->
        raise message
    end
  end

  @doc """
  Update the value of the named entry in the Scope.

  Search starts backwards from the last, and only the first entry matching the specified name is updated.
  If no entry matching the specified name is found, a new one is added.

  Returns an error when trying to update the value of a constant.
  """
  def set_value(%__MODULE__{resource: resource} = scope, name, value) do
    case Rhai.Native.scope_set_value(resource, name, value) do
      {:ok, _} ->
        {:ok, scope}

      error ->
        error
    end
  end

  @doc """
  Update the value of the named entry in the Scope.

  Search starts backwards from the last, and only the first entry matching the specified name is updated.
  If no entry matching the specified name is found, a new one is added.

  Raises when trying to update the value of a constant.
  """
  def set_value!(%__MODULE__{} = scope, name, value) do
    case set_value(scope, name, value) do
      {:ok, _} ->
        scope

      {:error, {:cannot_update_value_of_constant, message}} ->
        raise message
    end
  end

  @doc false
  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end

  defimpl Enumerable do
    def count(scope) do
      {:ok, Rhai.Scope.len(scope)}
    end

    def member?(scope, {name, value}) do
      {:ok, value == Rhai.Scope.get_value(scope, name)}
    end

    def reduce(%Rhai.Scope{resource: resource}, acc, fun) do
      resource
      |> Rhai.Native.scope_iter_collect()
      |> Enumerable.List.reduce(acc, fun)
    end

    # Since it returns `{:error, __MODULE__}`, a default implementation will be used.
    def slice(_), do: {:error, __MODULE__}
  end
end
