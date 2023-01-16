defmodule Rhai.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  targets = ~w(
    aarch64-apple-darwin
    x86_64-apple-darwin
    x86_64-unknown-linux-gnu
    x86_64-unknown-linux-musl
    arm-unknown-linux-gnueabihf
    aarch64-unknown-linux-gnu
    aarch64-unknown-linux-musl
    x86_64-pc-windows-msvc
    x86_64-pc-windows-gnu
  )

  use RustlerPrecompiled,
    otp_app: :rhai_rustler,
    crate: "rhai_rustler",
    base_url: "https://github.com/fabriziosestito/rhai_rustler/releases/download/v#{version}",
    force_build:
      Application.compile_env(:rustler_precompiled, [:force_build, :rhai_rustler], false) ||
        System.get_env("RHAI_RUSTLER_FORCE_BUILD") in ["1", "true"],
    version: version,
    targets: targets

  def eval(_, _) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
