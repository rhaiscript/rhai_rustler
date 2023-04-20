defmodule Rhai.Any do
  @moduledoc false

  @type t() ::
          number() | boolean() | String.t() | nil | [t()] | %{String.t() => t()}
end
