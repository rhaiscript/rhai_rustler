defmodule Rhai.Any do
  @moduledoc """
  Rhai types
  """

  @type t() ::
          number() | boolean() | String.t() | nil | [t()] | %{String.t() => t()}
end
