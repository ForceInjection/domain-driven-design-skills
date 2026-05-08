---
name: calculator-utils
description: Performs basic arithmetic calculations including addition, subtraction, multiplication, and division. Use when the user needs to calculate numbers, perform math operations, or compute arithmetic expressions.
license: MIT
metadata:
  author: ai-labs
  version: "1.0"
---

# Calculator Utilities

A basic calculator utility that provides fundamental arithmetic operations via a Python script.

## How to Use

Run the calculator script with an operation and numbers:

```bash
python scripts/calculator.py <operation> <numbers...>
```

## Operations

### Add
Adds all numbers together.

```bash
python scripts/calculator.py add 5 3
# Output: 8

python scripts/calculator.py add 10 20 30
# Output: 60
```

### Subtract
Subtracts all subsequent numbers from the first number.

```bash
python scripts/calculator.py subtract 10 4
# Output: 6

python scripts/calculator.py subtract 100 25 15
# Output: 60
```

### Multiply
Multiplies all numbers together.

```bash
python scripts/calculator.py multiply 6 7
# Output: 42

python scripts/calculator.py multiply 2 3 4
# Output: 24
```

### Divide
Divides the first number by all subsequent numbers.

```bash
python scripts/calculator.py divide 20 4
# Output: 5.0

python scripts/calculator.py divide 100 2 5
# Output: 10.0
```

## Error Handling

- **Division by zero**: Returns an error message
- **Invalid input**: Non-numeric values will show an error
- **Missing arguments**: Shows usage instructions

## Examples

```bash
# Simple addition
python scripts/calculator.py add 100 50
# Output: 150

# Chain subtraction
python scripts/calculator.py subtract 1000 250 150 100
# Output: 500

# Multiply decimals
python scripts/calculator.py multiply 3.14 2
# Output: 6.28

# Division with decimals
python scripts/calculator.py divide 22 7
# Output: 3.142857142857143
```
