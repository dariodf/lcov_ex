# lcov_ex

Test coverage module to generate a `lcov.info` file for an Elixir project.

The docs can be found at [https://hexdocs.pm/lcov_ex](https://hexdocs.pm/lcov_ex).

## Why

### Visual line coverage

Many test coverage tools use [`lcov`](https://manpages.debian.org/stretch/lcov/geninfo.1.en.html#FILES) files as an input.

You can use it as I do to watch coverage progress in the following editors:

- VSCode:
  - Using the [Coverage Gutters](https://github.com/ryanluker/vscode-coverage-gutters) extension.
  - Using the [Koverage](https://marketplace.visualstudio.com/items?itemName=tenninebt.vscode-koverage) extension (add "cover" in settings as coverage folder, or output the report to the "coverage" folder, see below).
- Atom, using the [lcov-info](https://atom.io/packages/lcov-info) extension (it requires you to change the output folder to "coverage", see below).

Please let me know if you made it work in your previously unlisted favorite editor. Or, if you're really nice, just add it to this list yourself :slightly_smiling_face:

### Coverage report in CI

You can use `mix lcov --exit` in a Github Action CI to safely run your tests and generate the lcov file, and then use that with [a report tool](https://github.com/marketplace/actions/lcov-pull-request-report) to generate a comment with code coverage information in your pull requests.

See [this project's CI configuration](https://github.com/dariodf/lcov_ex/blob/master/.github/workflows/elixir.yml) for more info on how to set it up.

## Installation

Add to your dependencies:

```elixir
  def deps do
    [
      {:lcov_ex, "~> 0.3", only: [:dev, :test], runtime: false}
    ]
  end
```

## Usage

```shell
mix lcov
```

File should be created at `./cover/lcov.info` by default.

### Options

#### `--quiet`

To run silently use the `--quiet` option:

```shell
mix lcov --quiet
```

#### `--output <folder>`

To output the file to a different folder, use the `--output` option:

```shell
mix lcov --output coverage
...
Coverage file successfully created at coverage/lcov.info
```

#### `--exit`

Exits with a non-zero exit code if the tests fail: the same code that `mix test` would have exited with.

``` shell
mix lcov --exit
```

### Umbrella projects

By default, running `mix lcov` at the umbrella level will generate the coverage report for all individual apps and then compile them into a single file at `./cover/lcov.info`.

#### `--keep`

For umbrella projects you can choose to keep the individual apps lcov files with the `--keep` option:

```shell
mix lcov --keep
...
Coverage file for my_app created at apps/my_app/cover/lcov.info
Coverage file for my_other_app created at apps/my_other_app/cover/lcov.info

Coverage file for umbrella created at cover/lcov.info
```

#### Run for single umbrella app

You can choose to run `mix lcov` for any single app inside an umbrella project by passing its folder as an argument.

```shell
mix lcov /apps/myapp
```

File should be created at `./apps/my_app/cover/lcov.info` by default.

### As test coverage tool

Alternatively, you can set up `LcovEx` as your test coverage tool in your project configuration:

```elixir
  def project do
    [
      ...
      test_coverage: [tool: LcovEx, output: "cover"],
      ...
    ]
```

And then, run with:

```shell
mix test --cover
```

The `output` option indicates the output folder for the generated file.

Optionally, the `ignore_paths` option can be a list of path prefixes to ignore when generating the coverage report.

```elixir
  def project do
    [
      ...
      test_coverage: [tool: LcovEx, output: "cover", ignore_paths: ["test/", "deps/"]]
      ...
    ]
```

## TODOs

- Add missing `FN` lines, for the sake of completion.
