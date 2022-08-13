# EvalEx

[![CI](https://github.com/fabriziosestito/evalex/actions/workflows/main.yaml/badge.svg)](https://github.com/fabriziosestito/evalex/actions/workflows/main.yaml)
[![Rust CI](https://github.com/fabriziosestito/evalex/actions/workflows/rust-ci.yaml/badge.svg)](https://github.com/fabriziosestito/evalex/actions/workflows/rust-ci.yaml)
[![NIFs precompilation](https://github.com/fabriziosestito/evalex/actions/workflows/release.yaml/badge.svg)](https://github.com/fabriziosestito/evalex/actions/workflows/release.yaml)
[![Hex.pm](https://img.shields.io/hexpm/v/evalex.svg)](https://hex.pm/packages/evalex)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/evalex/)

---

EvalEx is a powerful expression evaluation library for Elixir, based on [evalexpr](https://github.com/ISibboI/evalexpr) using [rustler](https://github.com/rusterlium/rustler).

## About

EvalEx evaluates expressions in Elixir, leveraging the [evalexpr](https://github.com/ISibboI/evalexpr) crate tiny scripting language.

Please refer to the [evalexpr documentation](https://docs.rs/evalexpr/latest/evalexpr/index.html) for extended information about the language.

## Installation

Add `:evalex` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:evalex, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> EvalEx.eval("1 + 1")
{:ok, 2}

iex> EvalEx.eval("a * b", %{"a" => 10, "b" => 10})
{:ok, 100}

iex> EvalEx.eval("a == b", %{"a" => "tonio", "b" => "wanda"})
{:ok, false}

iex> EvalEx.eval("a != b", %{"a" => "tonio", "b" => "wanda"})
{:ok, true}

iex> EvalEx.eval("len(a)", %{"a" => [1, 2, 3]})
{:ok, 3}

iex> EvalEx.eval("a + b", %{"a" => 10})
{:error,
 {:variable_identifier_not_found,
  "Variable identifier is not bound to anything by context: \"b\"."}}
```

### Precompile expressions

T.B.D.

## Type conversion table

Elixir Types are converted to EvalEx types (and back) as follows:

| Elixir     | EvalEx                |
| ---------- | --------------------- |
| integer()  | Int                   |
| float()    | Float                 |
| bool()     | Boolean               |
| String.t() | String                |
| list()     | Tuple                 |
| tuple()    | Tuple                 |
| nil()      | Empty                 |
| pid()      | Empty (not supported) |
| ref()      | Empty (not supported) |
| fun()      | Empty (not supported) |
| map()      | Empty (not supported) |

## Rustler precompiled

By default, **you don't need the Rust toolchain installed** because the lib will try to download
a precompiled NIF file.
In case you want to force compilation set the
`EVALEX_FORCE_BUILD` environment variable to `true` or `1`.

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

## License

This library is licensed under Apache 2.0 License. See [LICENSE](LICENSE) for details.

## Links

- [evalexpr](https://github.com/ISibboI/evalexpr) The Rust crate doing most of the dirty work.
- [RustlerPrecompiled](https://github.com/philss/rustler_precompiled) Use precompiled NIFs from trusted sources in your Elixir code.
- [NimbleLZ4](https://github.com/whatyouhide/nimble_lz4) Major inspiration for the RustlerPrecompiled GitHub actions workflow and general setup.
