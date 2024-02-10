# ExDbmigrate
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_dbmigrate/)
[![Hex.pm](https://img.shields.io/hexpm/dt/ex_dbmigrate.svg)](https://hex.pm/packages/ex_dbmigrate)
[![License](https://img.shields.io/hexpm/l/ex_dbmigrate.svg)](https://github.com/mithereal/ex_dbmigrate/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/mithereal/ex_dbmigrate.svg)](https://github.com/mithereal/ex_dbmigrate/commits/master)
[![Build Status](https://circleci.com/gh/mithereal/ex_dbmigrate.svg?style=svg)](https://github.com/mithereal/ex_dbmigrate)

**Generate phoenix schemas, html, json and live from existing database**

## Installation

- install elixir "https://elixir-lang.org/install.html"
- install phoenix "https://hexdocs.pm/phoenix/installation.html"

```bash
 mix archive.install hex phx_new
 mix phx.new app_name
 cd app_name
```


If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_dbmigrate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_dbmigrate, ">= 0.0.0"}
  ]
end
```

## Usage: 
```bash
mix ExDbmigrate.Gen.Migration
mix ExDbmigrate.Gen.Relation
mix ExDbmigrate.Gen.Schema
mix ExDbmigrate.Gen.Html
mix ExDbmigrate.Gen.Json
mix ExDbmigrate.Gen.Live
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_dbmigrate>.

