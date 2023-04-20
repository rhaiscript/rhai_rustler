defmodule Rhai.Any do
  @type t() ::
          number() | boolean() | String.t() | nil | [t()] | %{String.t() => t()}
end
