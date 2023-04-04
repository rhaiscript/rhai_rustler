defmodule Rhai.TestDylibModule do
  @moduledoc """
  This module is used to test the integration with rhai-dylib.

  Rustler is needed to trigger the compilation of the crate, and it does not export NIFs.
  """

  use Rustler,
    otp_app: :rhai_rustler,
    crate: :test_dylib_module

  if :os.type() == {:unix, :darwin} do
    @after_compile __MODULE__

    # This is a workaround since Rustler creates a .so file on macOS,
    # but the dylib module resolver expects a .dylib file.
    def __after_compile__(_, _) do
      path = File.cwd!() <> "/priv/native/libtest_dylib_module"

      File.ln_s(path <> ".so", path <> ".dylib")
    end
  end
end
