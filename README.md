# Rhai rustler

[![CI](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/main.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/main.yaml)
[![Rust CI](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/rust-ci.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/rust-ci.yaml)
[![NIFs precompilation](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/release.yaml/badge.svg)](https://github.com/fabriziosestito/rhai_rustler/actions/workflows/release.yaml)
[![Hex.pm](https://img.shields.io/hexpm/v/rhai_rustler.svg)](https://hex.pm/packages/rhai_rustler)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/rhai_rustler/)

Elixir NIF bindings for Rhai, an embedded scripting language and engine for Rust

Please refer to [The Rhai Book](https://rhai.rs/book/index.html) for extended information about the language.

## Installation

Add `:rhai_rustler` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rhai_rustler, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> Rhai.eval("1 + 1")
{:ok, 2}

iex> Rhai.eval("a * b", %{"a" => 10, "b" => 10})
{:ok, 100}

iex> Rhai.eval("a == b", %{"a" => "tonio", "b" => "wanda"})
{:ok, false}

iex> Rhai.eval("a != b", %{"a" => "tonio", "b" => "wanda"})
{:ok, true}

iex> Rhai.eval("a.len()", %{"a" => [1, 2, 3]})
{:ok, 3}

iex> Rhai.eval("a.filter(|v| v > 3)", %{"a" => [1, 2, 3, 5, 8, 13]})
{:ok, [5, 8, 13]}

iex> Rhai.eval("a.b", %{"a" => %{"b" => 1}})
{:ok, 1}

iex> Rhai.eval("a + b", %{"a" => 10})
{:error, {:variable_not_found, "Variable not found: b (line 1, position 5)"}}
```

## Type conversion table

Elixir Types are converted to Rhai types (and back) as follows:

| Elixir                        | Rhai                  |
| ----------------------------- | --------------------- |
| integer()                     | Integer               |
| float()                       | Float                 |
| float()                       | Decimal               |
| bool()                        | Boolean               |
| String.t()                    | String                |
| String.t()                    | Char                  |
| list()                        | Array                 |
| tuple()                       | Array                 |
| %{ String.t() => rhai_any() } | Object map            |
| nil()                         | Empty                 |
| pid()                         | Empty (not supported) |
| ref()                         | Empty (not supported) |
| fun()                         | Empty (not supported) |
| map()                         | Empty (not supported) |

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
