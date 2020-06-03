# lcov_ex

Test coverage module to generate a `lcov.info` file for an Elixir project.

The docs can be found at [https://hexdocs.pm/lcov_ex](https://hexdocs.pm/lcov_ex).

## Why

Many test coverage tools use `lcov` files as an input to generate reports.

I use it to see inline coverage progress in vscode with the [Coverage Gutters extension](https://github.com/ryanluker/vscode-coverage-gutters).

## Installation

Add to your dependencies:

```elixir
def deps do
  [
    {:lcov_ex, "~> 0.1.0"}
  ]
end
```

Then, select `LcovEx` as your test coverage tool in your project configuration:

```elixir
def project do
  [
    ...
    test_coverage: [tool: LcovEx],
    ...
  ]
```

## Usage

Run tests with coverage:

```shell
mix test --cover
```

File should be created at `./cover/lcov.info` by default.

## TODOs

- Add missing `FN` lines, for the sake of completion.
- Make it work as a `Task` to avoid overwriting the `test_coverage` tool config.
