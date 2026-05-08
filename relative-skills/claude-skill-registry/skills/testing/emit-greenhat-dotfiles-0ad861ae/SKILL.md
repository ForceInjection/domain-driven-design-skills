---
name: emit
description: |
  Use when working on the Miden compiler (`cargo miden`, `cargo-miden`) and its integration test suite, debugging compiler issues or failing tests, or implementing compiler changes and you need to inspect intermediate artifacts. Covers `MIDENC_EMIT` (the environment-variable equivalent of `--emit`) for emitting WAT/HIR/MASM (and related outputs), plus `MIDENC_EMIT_MACRO_EXPAND` for dumping macro-expanded Rust via `cargo expand` for integration-test fixtures.
---

# MIDENC Emit (Intermediate Artifacts) + Macro Expand

## Quick start

- Emit all intermediate IRs (WAT + HIR + MASM) into a `ir_dump` directory:
  - `MIDENC_EMIT=ir=ir_dump`
- Emit HIR to stdout:
  - `MIDENC_EMIT=hir=-`
- Emit MASM to a specific file:
  - `MIDENC_EMIT=masm=out.masm`
- Dump macro-expanded Rust for integration tests into a `ir_dump` directory:
  - `MIDENC_EMIT_MACRO_EXPAND=ir_dump cargo make test`

## `MIDENC_EMIT` (same syntax as `--emit`)

### Syntax

- Set `MIDENC_EMIT` to a comma-delimited list of `KIND[=PATH]` specs, e.g.:
  - `MIDENC_EMIT=wat,hir,masm`
  - `MIDENC_EMIT=ir=ir_dump`

### Useful kinds for pipeline debugging

- `wat`: WebAssembly text format (`.wat`)
- `hir`: Miden High-level IR (`.hir`)
- `masm`: Miden Assembly text (`.masm`)
- Shorthands:
  - `ir`: emits `wat,hir,masm` together (WAT + HIR + MASM)

### PATH rules (practical)

- Omit `=PATH` to use the CWD.
- Use `=DIR` to emit `DIR/<stem>.<ext>` for each requested output type:
  - Example: `MIDENC_EMIT=ir=target/emit` writes `target/emit/<stem>.wat`, `target/emit/<stem>.hir`, `target/emit/<stem>.masm`.
- Use `=-` to write textual outputs to stdout (e.g. `hir=-`, `wat=-`, `masm=-`).
  - Note: `ir=-` is invalid; `ir` expects a directory (or no path).
- Use `=FILE` to write a single output to a specific file path:
  - Example: `MIDENC_EMIT=hir=my_dump.hir`.

## `MIDENC_EMIT_MACRO_EXPAND` (integration tests only)

When you need to see the actual Rust code after macros have expanded (helpful when debugging
fixtures that use proc-macros, attribute macros, derives, or cfg-gated code), enable macro expansion dumps.

### Behavior

- If `MIDENC_EMIT_MACRO_EXPAND` is unset: nothing happens.
- If set to an empty value or `1`: writes `*.expanded.rs` files into the current working directory.
- If set to any other non-empty value: treats it as an output directory (created if missing).
- The integration test harness runs `cargo expand` and writes one file per fixture/test:
  - `<test_name>.expanded.rs`

## Debugging workflow (recommended)

1. Reproduce on a single test case if possible.
2. Emit intermediate artifacts to a dedicated folder:
   - `MIDENC_EMIT=ir=target/emit/<case> ...`
3. If the failing test involves Rust fixtures/macros:
   - `MIDENC_EMIT_MACRO_EXPAND=target/expand/<case> ...`
