---
name: Using `argc` / `Argcfile`
description: Create and modify Argcfiles using the special syntax required. Use this when editing Argcfile.sh, @argc, or any shell script that contains `argc --argc-eval`.
---

## Argc

[Argc](https://github.com/sigoden/argc/) is a Bash command line framework that utilizes a special comment-driven syntax to provide a command runner and argument parser.

Here is a simple Argcfile.sh:

```bash
# @flag -F --foo  Flag param
# @option --bar   Option param
# @option --baz*  Option param (multi-occurs)
# @arg val*       Positional param

eval "$(argc --argc-eval "$0" "$@")"

echo foo: $argc_foo
echo bar: $argc_bar
echo baz: ${argc_baz[@]}
echo val: ${argc_val[@]}
```

Run the script with some sample arguments:

```bash
./example.sh -F --bar=xyz --baz a --baz b v1 v2
```

Argc parses these arguments and creates variables prefixed with argc_:

```
foo: 1
bar: xyz
baz: a b
val: v1 v2
```

You can also run ./example.sh --help to see the automatically generated help information for your CLI.

## Comment Tags

Comment tags are standard Bash comments prefixed with `@` and a specific tag. They provide instructions to Argc for configuring your script's functionalities.

| Tag         | Description                           |
| :---------- | ------------------------------------- |
| `@describe` | Sets the description for the command. |
| `@cmd`      | Defines a subcommand.                 |
| `@alias`    | Sets aliases for the subcommand.      |
| `@arg`      | Defines a positional argument.        |
| `@option`   | Defines an option argument.           |
| `@flag`     | Defines a flag argument.              |
| `@env`      | Defines an environment variable.      |
| `@meta`     | Adds metadata.                        |

Links:

- [Specification](https://github.com/sigoden/argc/blob/main/docs/specification.md) for the grammar and usage of all the comment tags.
- [Variables](https://github.com/sigoden/argc/blob/main/docs/variables.md) that are predefined by argc.
- [Examples](https://github.com/sigoden/argc/tree/main/examples) for particularly complex scenarios.
