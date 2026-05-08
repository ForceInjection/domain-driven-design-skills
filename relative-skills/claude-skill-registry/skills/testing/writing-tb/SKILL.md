---
name: writing-tb
description:
  Provides svc_unit.sv testbench framework, macros (TEST_CLK_NS, CHECK_EQ,
  etc.), and template. Triggers when creating or modifying _tb.sv files.
---

# Writing a Testbench

## Framework

Use `svc_unit.sv` from `rtl/common/`. File location: `tb/<category>/` matching
the module's rtl location.

## Testbench Template

```systemverilog
`include "svc_unit.sv"
`include "svc_module_name.sv"

module svc_module_name_tb;
  //
  // Clock and reset
  //
  `TEST_CLK_NS(clk, 10);
  `TEST_RST_N(clk, rst_n);

  //
  // Testbench signals
  //
  logic       in_valid;
  logic [7:0] in_data;
  logic       in_ready;
  logic       out_valid;
  logic [7:0] out_data;
  logic       out_ready;

  //
  // UUT instantiation
  //
  svc_module_name uut (
      .clk      (clk),
      .rst_n    (rst_n),
      .in_valid (in_valid),
      .in_data  (in_data),
      .in_ready (in_ready),
      .out_valid(out_valid),
      .out_data (out_data),
      .out_ready(out_ready)
  );

  //
  // Signal initialization
  //
  always_ff @(posedge clk) begin
    if (~rst_n) begin
      in_valid  <= 1'b0;
      in_data   <= 8'h00;
      out_ready <= 1'b1;
    end
  end

  //
  // Tests
  //
  task automatic test_reset();
    `CHECK_FALSE(out_valid);
    `CHECK_TRUE(in_ready);
  endtask

  task automatic test_basic();
    in_valid = 1'b1;
    in_data  = 8'hA5;
    `TICK(clk);
    `CHECK_WAIT_FOR(clk, out_valid, 10);
    `CHECK_EQ(out_data, 8'hA5);
  endtask

  //
  // Test suite
  //
  `TEST_SUITE_BEGIN(svc_module_name_tb);
  `TEST_CASE(test_reset);
  `TEST_CASE(test_basic);
  `TEST_SUITE_END();
endmodule
```

## Key Macros

### Setup

- `TEST_CLK_NS(clk, period_ns)` - Create clock
- `TEST_RST_N(clk, rst_n)` - Create reset (active 5 cycles)

### Test Organization

- `TEST_SUITE_BEGIN(name)` - Start test suite
- `TEST_SUITE_END()` - End test suite
- `TEST_CASE(task_name)` - Register a test
- `TICK(clk)` - Advance one clock cycle

### Assertions

- `CHECK_TRUE(condition)` - Verify true
- `CHECK_FALSE(condition)` - Verify false
- `CHECK_EQ(a, b)` - Verify equal
- `CHECK_NEQ(a, b)` - Verify not equal
- `CHECK_LT(a, b)` / `CHECK_GT(a, b)` - Comparisons
- `CHECK_LTE(a, b)` / `CHECK_GTE(a, b)` - Comparisons
- `CHECK_WAIT_FOR(clk, condition, max_cycles)` - Wait for condition

## Rules

- **First test must be reset test** - Always test post-reset state
- **Use `automatic` for all tasks** - Proper variable scoping
- **Initialize all signals in reset block** - Use `always_ff` with `~rst_n`
- **Use non-blocking assignments** (`<=`) in reset block

## Running Tests

```bash
make <module>_tb           # Run specific testbench
make <module>_tb RUN=test  # Run specific test case
make tb                    # Run all testbenches
```

## Debugging

VCD files generated at `.build/<module>.vcd`:

```bash
gtkwave .build/<module>.vcd &
```

## Reference

See `tb/common/svc_arbiter_tb.sv` for a complete example.

For full details see `docs/tb.md`
