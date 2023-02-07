defmodule Rhai.Engine do
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

  def wrap_resource(resource) do
    %__MODULE__{
      resource: resource,
      reference: make_ref()
    }
  end

  @spec new :: t()
  def new do
    Rhai.Native.new()  
  end
end
