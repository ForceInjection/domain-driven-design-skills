---
name: moonbit-refactoring
description: Refactor MoonBit codebases by minimizing public APIs, modularizing packages, converting free functions to methods/chaining, using ArrayView/StringView pattern matching, adding Dafny-style loop specs, and improving tests/coverage without regressions. Use when asked to refactor or modernize MoonBit projects.
---

# MoonBit Refactoring Skill

## Intent
- Preserve behavior and public contracts unless explicitly changed.
- Minimize the public API to what callers require.
- Prefer declarative style and pattern matching over incidental mutation.
- Use view types (ArrayView/StringView/BytesView) to avoid copies.
- Add tests and docs alongside refactors.

## Workflow
- Inventory public APIs and call sites (`moon doc`, `moon ide find-references`).
- Pick one refactor theme (API minimization, pattern matching, loop style).
- Apply the smallest safe change.
- Update docs/tests in the same patch.
- Run `moon check`, then `moon test`.
- Use coverage to target missing branches.

## Minimize Public API and Modularize
- Remove `pub` from helpers; keep only required exports.
- Use constructors like `Type::new` instead of public literal construction.
- Move helpers into `internal/` packages to block external imports.
- Split large files by feature; files do not define modules in MoonBit.

Example:
```mbt
// Before: public construction everywhere
pub struct Closure { ... }

// After: controlled construction
pub struct Closure { ... }
pub fn Closure::new(id : Int, params : Array[String]) -> Closure { { id, params } }
```

## Convert Free Functions to Methods + Chaining
- Move behavior onto the owning type for discoverability.
- Use `..` for fluent, mutating chains when it reads clearly.

Example:
```mbt
// Before
fn reader_next(r : Reader) -> Char? { ... }
let ch = reader_next(r)

// After
fn Reader::next(self : Reader) -> Char? { ... }
let ch = r.next()
```

Example (chaining):
```mbt
buf..write_string("#\\")..write_char(ch)
```

## Prefer Explicit Qualification
- Use `@pkg.fn` instead of `use` when clarity matters.
- Keep call sites explicit during wide refactors.

Example:
```mbt
let n = @parser.parse_number(token)
```

## Simplify Constructors When Type Is Known
- Drop `TypePath::Constr` when the surrounding type is known.

Example:
```mbt
match tree {
  Leaf(x) => x
  Node(left~, x, right~) => left.sum() + x + right.sum()
}
```

## Pattern Matching and Views
- Pattern match arrays directly; the compiler inserts ArrayView implicitly.
- Use `..` in the middle to match prefix and suffix at once.
- Pattern match strings directly; avoid converting to `Array[Char]`.
- `String`/`StringView` indexing yields `UInt16` code units.
- Use `for ch in s` for Unicode-aware iteration.

Examples:
```mbt
match items {
  [] => ()
  [head, ..tail] => handle(head, tail)
  [..prefix, mid, ..suffix] => handle_mid(prefix, mid, suffix)
}
```

```mbt
match s {
  "" => ()
  [.."let", ..rest] => handle_let(rest)
  _ => ()
}
```

## Use Nested Patterns and `is`
- Replace indexing with structural patterns.
- Use nested patterns to encode invariants.
- Use `is` patterns inside `if`/`guard` to keep branches concise.

Example:
```mbt
match token {
  Some(Ident([.."@", ..rest])) => handle_at(rest)
  Some(Ident(name)) => handle_ident(name)
  None => ()
}
```

## Prefer Range Loops for Simple Indexing
- Use `for i in start..<end { ... }` for simple index loops.
- Use `for i in start..=end { ... }` when the upper bound is inclusive.
- Keep functional-state `for` loops for algorithms that update state.

Example:
```mbt
// Before
for i = 0; i < len; {
  items.push(fill)
  continue i + 1
}

// After
for i in 0..<len {
  items.push(fill)
}
```

## Loop Specs (Dafny-Style Comments)
- Add specs for functional-state loops.
- Skip invariants for simple `for x in xs` loops.
- Add TODO when a decreases clause is unclear (possible bug).

Example:
```mbt
for i = 0, acc = 0; i < xs.length(); {
  // invariant : 0 <= i && i <= xs.length()
  // invariant : acc == sum(xs[:i])
  // decreases : xs.length() - i
  acc = acc + xs[i]
  i = i + 1
} else { acc }
```

Example (TODO):
```mbt
// TODO(invariant) : explain loop termination for this branch
```

## Tests and Docs
- Prefer black-box tests in `*_test.mbt` or `*.mbt.md`.
- Add docstring tests with `mbt check` for public APIs.

Example:
```mbt
///|
/// Return the last element of a non-empty array.
///
/// # Example
/// ```mbt check
/// test {
///   inspect(last([1, 2, 3]), content="3")
/// }
/// ```
pub fn last(xs : Array[Int]) -> Int { ... }
```

## Coverage-Driven Refactors
- Use coverage to target missing branches through public APIs.
- Prefer small, focused tests over white-box checks.

Commands:
```bash
moon coverage analyze -- -f summary
moon coverage analyze -- -f caret -F path/to/file.mbt
```

## Moon IDE Commands
```bash
moon doc "<query>"
moon ide outline <dir|file>
moon ide find-references <symbol>
moon ide peek-def <symbol>
moon check
moon test
moon info
```

## Learning Log Template
Use one entry per refactor so the guide stays reusable.

```
## YYYY-MM-DD: Title
- Problem: <what was unclear>
- Change: <what was refactored>
- Result: <impact on API/tests/coverage>
- Example:
<before/after or isolated snippet>
```
