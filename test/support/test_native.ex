defmodule Rhai.TestDylibModule do
  @moduledoc """
  This module is used to test the integration with rhai-dylib.

  Rustler is needed to trigger the compilation of the crate, and it does not export NIFs.
  """

  use Rustler,
    otp_app: :rhai_rustler,
    crate: :test_dylib_module
end
