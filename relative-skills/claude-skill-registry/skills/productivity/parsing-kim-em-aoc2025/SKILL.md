---
name: parsing
description: Use the lean4-parser library for parsing structured input. Invoke when implementing parsers for AoC puzzles or other text processing tasks in Lean.
allowed-tools: Read, Edit, Write
---

# Parsing Skill: lean4-parser Library

When parsing structured input (especially for AoC puzzles), use the **lean4-parser** library instead of manual string splitting.

## Installation

Already configured in `lakefile.toml`:
```toml
[[require]]
name = "Parser"
git = "https://github.com/fgdorais/lean4-parser"
rev = "main"
```

## Import

```lean
import Parser
open Parser Char
```

## Quick Reference

### Parser Types

```lean
-- Use SimpleParser for good error messages
abbrev MyParser := SimpleParser Substring Char
```

### Running Parsers

```lean
match myParser.run inputString with
| .ok _ result => -- use result
| .error _ e => -- handle error
```

### Common Combinators

| Combinator | Description |
|------------|-------------|
| `ASCII.parseNat` | Parse natural number |
| `ASCII.parseInt` | Parse signed integer |
| `char c` | Match exact character |
| `string s` | Match exact string |
| `space`, `whitespace` | Whitespace matching |
| `eol` | End of line (LF or CRLF) |
| `endOfInput` | Assert at end of input |
| `takeMany p` | Zero or more, collect results |
| `dropMany p` | Zero or more, discard |
| `sepBy p sep` | Items separated by delimiter |
| `first [p1, p2]` | Try alternatives |
| `test p` | Check without consuming (returns Bool) |
| `optional p` | Zero or one |

### Example: Parse Numbers from Line

```lean
def parseLine : SimpleParser Substring Char (List Nat) := do
  sepBy ASCII.parseNat (dropMany1 (char ' '))
```

### Example: Parse Coordinates

```lean
def parseCoord : SimpleParser Substring Char (Int × Int) := do
  let _ ← char '('
  let x ← ASCII.parseInt
  let _ ← char ','
  dropMany space
  let y ← ASCII.parseInt
  let _ ← char ')'
  return (x, y)
```

### Example: Parse Key-Value Pairs

```lean
def parseKeyValue : SimpleParser Substring Char (String × Int) := do
  let key ← takeMany1 alpha
  let _ ← char ':'
  dropMany space
  let value ← ASCII.parseInt
  return (⟨key⟩, value)
```

### Example: Parse with Alternatives

```lean
def parseDirection : SimpleParser Substring Char Int := first [
  string "up" *> pure 1,
  string "down" *> pure (-1),
  string "left" *> pure 0,
  string "right" *> pure 0
]
```

### Example: Looping Until End

```lean
def parseAll : SimpleParser Substring Char (List Int) := do
  let mut results := []
  while !(← test endOfInput) do
    let n ← ASCII.parseInt
    results := results ++ [n]
    dropMany (char ' ' <|> char '\n')
  return results
```

## Documentation

- Full docs: https://www.dorais.org/lean4-parser/doc/
- Repository: https://github.com/fgdorais/lean4-parser
