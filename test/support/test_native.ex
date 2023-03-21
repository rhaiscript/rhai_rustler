defmodule Rhai.TestDylibModule do
  use Rustler,
    otp_app: :rhai_rustler,
    crate: :test_dylib_module
end
