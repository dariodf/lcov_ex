# lcov_ex

Test coverage module to generate a `lcov.info` file for an Elixir project.

The docs can be found at [https://hexdocs.pm/lcov_ex](https://hexdocs.pm/lcov_ex).

## Why

Many test coverage tools use [`lcov` files](https://manpages.debian.org/stretch/lcov/geninfo.1.en.html#FILES) as an input to generate reports.

You can use it as I do to watch inline coverage progress with the following editors:

- VSCode, using the [Coverage Gutters](https://github.com/ryanluker/vscode-coverage-gutters) extension.
- Atom, using the [lcov-info](https://atom.io/packages/lcov-info) extension (it requires you to change the output folder to "coverage", see below).

Please let me know if you made it work in your previously unlisted favorite editor. Or, if you're really nice, just add it to this list yourself :slightly_smiling_face:

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
    test_coverage: [tool: LcovEx, output: "cover"],
    ...
  ]
```

The `output` option indicates the output folder for the generated file.

## Usage

Run tests with coverage:

```shell
mix test --cover
```

File should be created at `./cover/lcov.info` by default.

## TODOs

- Add missing `FN` lines, for the sake of completion.
- Make it work as a `Task` to avoid overwriting the `test_coverage` tool config.
