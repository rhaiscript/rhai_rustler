defmodule EvalEx.Native do
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
    otp_app: :evalex,
    crate: "evalex",
    base_url: "https://github.com/fabriziosestito/evalex/releases/download/v#{version}",
    force_build: System.get_env("EVALEX_FORCE_BUILD") in ["1", "true"],
    version: version,
    targets: targets

  def eval(_, _) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def eval_precompiled_expression(_, _) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def precompile_expression(_) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
