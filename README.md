# rhai_rustler

[![CI](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/main.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/main.yaml)
[![Rust CI](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/rust-ci.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/rust-ci.yaml)
[![NIFs precompilation](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/release.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/release.yaml)
[![Hex.pm](https://img.shields.io/hexpm/v/rhai_rustler.svg)](https://hex.pm/packages/rhai_rustler)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/rhai_rustler/)

Elixir NIF bindings for Rhai, a tiny, simple and fast embedded scripting language for Rust that gives you a safe and easy way to add scripting to your applications.

Please refer to [The Rhai Book](https://rhai.rs/book/index.html) for extended information about the language.

## Installation

Add `:rhai_rustler` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rhai_rustler, "~> 1.0.0"}
  ]
end
```

## Features

`rhai_rustler` exposes a subset of the Rhai API to Elixir:

- [Engine]() - [Rhai Book](https://rhai.rs/book/engine/index.html) - [docs.rs](https://docs.rs/rhai/latest/rhai/struct.Engine.html)
- [Scope]() - [Rhai book](https://rhai.rs/book/engine/scope.html) - [docs.rs](https://docs.rs/rhai/latest/rhai/struct.Scope.html)
- [AST]() - [Rhai book](https://rhai.rs/book/engine/ast.html) - [docs.rs](https://docs.rs/rhai/latest/rhai/struct.Ast.html)

Note that not all the Rhai API features are supported. For instance, advanced and low-level APIs are not exposed.

If any usage patterns become apparent, they will be included in the future.

Please refer to [NIF bindings](guides/nif-bindings.md) to see the methods supported by the Elixir NIF.

The Elixir NIF provides a way to extend Rhai with external native Rust modules, see: [Extending Rhai with external native Rust modules](#extending-rhai-with-external-native-rust-modules) and [rhai_dylib](https://github.com/rhaiscript/rhai-dylib) for more information.

To check the supported types conversion, see [Type conversion table](#type-conversion-table).

## Usage patterns

### "Hello Rhai"

```elixir
engine = Rhai.Engine.new()

{:ok, "Hello Rhai!"} = Rhai.Engine.eval(engine, "\"Hello Rhai!\"")
```

### Eval

```elixir
engine = Rhai.Engine.new()

# Simple evaluation
{:ok, 2} = Rhai.Engine.eval(engine, "1 + 1")

# Evaluation with scope
scope = Rhai.Scope.new() |> Rhai.Scope.push("a", 10) |> Rhai.Scope.push("b", 3)
{:ok, 30} = Rhai.Engine.eval_with_scope(engine, scope, "a * b")
```

### AST

```elixir
engine = Rhai.Engine.new()
scope = Rhai.Scope.new() |> Rhai.Scope.push_constant("a", 10) |> Rhai.Scope.push_constant("b", 3)

{:ok, %Rhai.AST{} = ast} = Rhai.Engine.compile_with_scope(engine, scope, "a * b")
{:ok, 30} = Rhai.Engine.eval_ast(engine, ast)

# AST can be shared between engines
task = Task.async(fn -> Rhai.Engine.eval_ast(Rhai.Engine.new(), ast) end)
{:ok, 30} = Task.await(task)
```

### Raw Engine

```elixir
engine = Rhai.Engine.new_raw()

# Returns an error since BasicArrayPackage is not registered
{:error, {:function_not_found, _}} = Rhai.Engine.eval(engine, "[1, 2, 3].find(|x| x > 2)")

# Please refer to https://rhai.rs/book/rust/packages/builtin.html for more information about packages
engine = Rhai.Engine.register_package(engine, :basic_array)
{:ok, 3} = Rhai.Engine.eval(engine, "[1, 2, 3].find(|x| x > 2)")
```

### Extending rhai_rustler with external native Rust modules

`rhai_rustler` utilizes the `[rhai_dylib](https://github.com/rhaiscript/rhai-dylib)` library to expand the capabilities of Rhai by loading external native Rust modules. This allows users to introduce new functions, custom types, and operators.

[test_dylib_module](https://github.com/fabriziosestito/rhai_rustler/tree/main/native/test_dylib_module) serves as an example of how to create a dylib module. A [dummy rustler module](https://github.com/fabriziosestito/rhai_rustler/blob/main/test/support/test_dylib_module.ex) is employed to trigger the compilation process. This same approach can be adopted in real-world projects, such as when distributing the dylib module as a Hex package.

## Type conversion table

Elixir Types are converted to Rhai types (and back) as follows:

| Elixir                          | Rhai                  |
| ------------------------------- | --------------------- |
| integer()                       | Integer               |
| float()                         | Float                 |
| float()                         | Decimal               |
| bool()                          | Boolean               |
| String.t()                      | String                |
| String.t()                      | Char                  |
| list()                          | Array                 |
| tuple()                         | Array                 |
| %{ String.t() => Rhai.Any.t() } | Object map            |
| nil()                           | Empty                 |
| pid()                           | Empty (not supported) |
| ref()                           | Empty (not supported) |
| fun()                           | Empty (not supported) |
| map()                           | Empty (not supported) |

## Rustler precompiled

By default, **you don't need the Rust toolchain installed** because the lib will try to download
a precompiled NIF file.
In case you want to force compilation set the
`RHAI_RUSTLER_FORCE_BUILD` environment variable to `true` or `1`.

Precompiled NIFs are available for the following platforms:

- aarch64-apple-darwin
- x86_64-apple-darwin
- x86_64-unknown-linux-gnu
- x86_64-unknown-linux-musl
- arm-unknown-linux-gnueabihf
- aarch64-unknown-linux-gnu
- aarch64-unknown-linux-musl
- x86_64-pc-windows-msvc
- x86_64-pc-windows-gnu

### Release flow

Please follow [this guide](https://hexdocs.pm/rustler_precompiled/precompilation_guide.html#the-release-flow) when releasing a new version of the library.

## License

This library is licensed under Apache 2.0 License. See [LICENSE](LICENSE) for details.

## Links

- [rhai](https://github.com/rhaiscript/rhai) The Rust crate doing most of the dirty work.
- [RustlerPrecompiled](https://github.com/philss/rustler_precompiled) Use precompiled NIFs from trusted sources in your Elixir code.
- [NimbleLZ4](https://github.com/whatyouhide/nimble_lz4) Major inspiration for the RustlerPrecompiled GitHub actions workflow and general setup.
