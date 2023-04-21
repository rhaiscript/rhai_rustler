defmodule Rhai.Package do
  @moduledoc false

  @type t ::
          :arithmetic
          | :basic_array
          | :basic_blob
          | :basic_fn
          | :basic_iterator
          | :basic_math
          | :basic_string
          | :basic_time
          | :bit_field
          | :core
          | :language_core
          | :logic
          | :more_string
          | :standard
end
