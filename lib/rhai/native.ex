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

  # legacy
  def eval(_, _), do: err()
  # engine
  def engine_new, do: err()
  def engine_compile(_engine, _script), do: err()
  def engine_eval(_engine, _script), do: err()
  def engine_eval_with_scope(_engine, _scope, _script), do: err()
  def engine_set_fail_on_invalid_map_property(_engine, _flag), do: err()
  def engine_fail_on_invalid_map_property(_engine), do: err()
  def engine_set_max_array_size(_engine, _flag), do: err()
  def engine_max_array_size(_engine), do: err()
  def engine_set_allow_anonymous_fn(_engine, _flag), do: err()
  def engine_allow_anonymous_fn(_engine), do: err()
  def engine_set_allow_if_expression(_engine, _flag), do: err()
  def engine_allow_if_expression(_engine), do: err()
  def engine_set_allow_loop_expressions(_engine, _flag), do: err()
  def engine_allow_loop_expressions(_engine), do: err()
  def engine_set_allow_looping(_engine, _flag), do: err()
  def engine_allow_looping(_engine), do: err()
  def engine_set_allow_shadowing(_engine, _flag), do: err()
  def engine_allow_shadowing(_engine), do: err()
  def engine_set_allow_statement_expression(_engine, _flag), do: err()
  def engine_allow_statement_expression(_engine), do: err()
  def engine_set_allow_switch_expression(_engine, _flag), do: err()
  def engine_allow_switch_expression(_engine), do: err()
  def engine_set_fast_operators(_engine, _flag), do: err()
  def engine_fast_operators(_engine), do: err()
  def engine_set_max_call_levels(_engine, _levels), do: err()
  def engine_max_call_levels(_engine), do: err()
  def engine_set_max_expr_depths(_engine, _max_expr_depth, _max_function_expr_depth), do: err()
  def engine_max_expr_depth(_engine), do: err()
  def engine_max_function_expr_depth(_engine), do: err()
  def engine_set_max_map_size(_engine, _max_size), do: err()
  def engine_max_map_size(_engine), do: err()
  def engine_set_max_modules(_engine, _modules), do: err()
  def engine_max_modules(_engine), do: err()
  def engine_set_max_operations(_engine, _operations), do: err()
  def engine_max_operations(_engine), do: err()
  def engine_set_max_string_size(_engine, _max_len), do: err()
  def engine_max_string_size(_engine), do: err()
  def engine_set_strict_variables(_engine, _flag), do: err()
  def engine_strict_variables(_engine), do: err()

  # scope
  def scope_new, do: err()
  def scope_with_capacity(_capacity), do: err()
  def scope_push_dynamic(_scope, _name, _value), do: err()
  def scope_push_constant_dynamic(_scope, _name, _value), do: err()
  def scope_contains(_scope, _name), do: err()
  def scope_is_constant(_scope, _name), do: err()
  def scope_get_value(_scope, _name), do: err()
  def scope_clear(_scope), do: err()
  def scope_clone_visible(_scope), do: err()
  def scope_is_empty(_scope), do: err()
  def scope_len(_scope), do: err()

  defp err, do: :erlang.nif_error(:nif_not_loaded)
end
