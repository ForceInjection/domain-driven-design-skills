---
name: implementing-axi
description:
  Provides SVC-specific AXI/AXI-Lite naming conventions, signal ordering, and
  available modules. Triggers when implementing AXI or AXI-Lite interfaces.
---

# AXI/AXI-Lite Interfaces

## Interface Naming

- **`s_`** prefix for subordinate (slave) interfaces - module receives
  transactions
- **`m_`** prefix for manager (master) interfaces - module initiates
  transactions
- **`axi_`** for full AXI, **`axil_`** for AXI-Lite

## Signal Naming Pattern

```
{s|m}_{axi|axil}_{channel}{signal}
```

Examples:

- `s_axi_awvalid` - subordinate AXI write address valid
- `m_axil_rready` - manager AXI-Lite read ready

## AXI Channels

### Write Channels

- **AW** - Write Address (awvalid, awready, awaddr, awid, awlen, awsize,
  awburst)
- **W** - Write Data (wvalid, wready, wdata, wstrb, wlast)
- **B** - Write Response (bvalid, bready, bid, bresp)

### Read Channels

- **AR** - Read Address (arvalid, arready, araddr, arid, arlen, arsize, arburst)
- **R** - Read Data (rvalid, rready, rdata, rid, rresp, rlast)

## AXI-Lite (Simplified)

AXI-Lite removes burst support:

- No `awlen`, `awsize`, `awburst`, `arlen`, `arsize`, `arburst`
- No `awid`, `arid`, `bid`, `rid`
- No `wlast`, `rlast`
- Single beat transactions only

## Common Parameters

```systemverilog
parameter AXI_ADDR_WIDTH = 32,
parameter AXI_DATA_WIDTH = 32,
parameter AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8,
parameter AXI_ID_WIDTH   = 4
```

## Port Declaration Example

### AXI Subordinate Interface

```systemverilog
// Write address channel
input  logic                      s_axi_awvalid,
input  logic [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
input  logic [  AXI_ID_WIDTH-1:0] s_axi_awid,
input  logic [               7:0] s_axi_awlen,
input  logic [               2:0] s_axi_awsize,
input  logic [               1:0] s_axi_awburst,
output logic                      s_axi_awready,

// Write data channel
input  logic                      s_axi_wvalid,
input  logic [AXI_DATA_WIDTH-1:0] s_axi_wdata,
input  logic [AXI_STRB_WIDTH-1:0] s_axi_wstrb,
input  logic                      s_axi_wlast,
output logic                      s_axi_wready,

// Write response channel
output logic                      s_axi_bvalid,
output logic [  AXI_ID_WIDTH-1:0] s_axi_bid,
output logic [               1:0] s_axi_bresp,
input  logic                      s_axi_bready,

// Read address channel
input  logic                      s_axi_arvalid,
input  logic [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
input  logic [  AXI_ID_WIDTH-1:0] s_axi_arid,
input  logic [               7:0] s_axi_arlen,
input  logic [               2:0] s_axi_arsize,
input  logic [               1:0] s_axi_arburst,
output logic                      s_axi_arready,

// Read data channel
output logic                      s_axi_rvalid,
output logic [AXI_DATA_WIDTH-1:0] s_axi_rdata,
output logic [  AXI_ID_WIDTH-1:0] s_axi_rid,
output logic [               1:0] s_axi_rresp,
output logic                      s_axi_rlast,
input  logic                      s_axi_rready
```

## Channel Ordering

Always group and order channels: **AW, W, B, AR, R**

## Response Codes

```systemverilog
localparam RESP_OKAY   = 2'b00;
localparam RESP_EXOKAY = 2'b01;
localparam RESP_SLVERR = 2'b10;
localparam RESP_DECERR = 2'b11;
```

## Available Modules

### Arbitration

- `svc_axi_arbiter.sv` - Full AXI arbiter (N managers → 1 subordinate)
- `svc_axi_arbiter_rd.sv` - Read channel arbiter
- `svc_axi_arbiter_wr.sv` - Write channel arbiter

### Routing

- `svc_axil_router.sv` - AXI-Lite router (1 manager → N subordinates)
- `svc_axil_router_rd.sv` - Read channel router
- `svc_axil_router_wr.sv` - Write channel router

### Protocol Conversion

- `svc_axi_axil_adapter.sv` - AXI to AXI-Lite adapter
- `svc_axi_burst_adapter.sv` - Burst adapter

### Memory Controllers

- `svc_axi_mem.sv` - AXI memory controller
- `svc_axil_sram_if.sv` - AXI-Lite SRAM interface
- `svc_axil_regfile.sv` - AXI-Lite register file

### Utilities

- `svc_axi_null.sv` - AXI sink (responds to all transactions)
- `svc_axi_tgen.sv` - Traffic generator
- `svc_axi_stats.sv` - Bus statistics collector

## Architecture Pattern

Most modules follow split read/write architecture with separate `_rd` and `_wr`
submodules handling each direction independently.

## Reference

See `rtl/axi/README.md` for full module listing. See
`rtl/axi/svc_axi_arbiter.sv` for a complete interface example.
