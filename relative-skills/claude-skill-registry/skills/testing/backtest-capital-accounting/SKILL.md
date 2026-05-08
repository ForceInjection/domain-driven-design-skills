---
name: backtest-capital-accounting
description: "Critical fix for backtest capital accounting when equity curves are inflated or drawdown metrics are meaningless"
author: Claude Code
date: 2025-12-16
---

# Backtest Capital Accounting - Research Notes

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2025-12-16 |
| **Goal** | Fix inflated equity curves and meaningless drawdown in backtests |
| **Environment** | Python 3.10, pandas, custom BacktestEngine |
| **Status** | Success |

## Context
Backtest engines often fail to properly track cash flows, leading to:
- Capital not deducted when positions open (inflated buying power)
- Sale proceeds not properly credited on close
- Equity calculation ignoring open position market values
- Meaningless max_drawdown metrics that can't trigger guardrails

The bug is subtle because the backtest "runs" without errors but produces unrealistic results.

## Verified Workflow

### 1. Correct `_open_position()` Implementation
```python
def _open_position(self, symbol, side, price, time, bar_idx, confidence):
    """Open position with proper capital accounting."""
    # Apply slippage first
    slippage = price * self.config.slippage_pct
    entry_price = price + (slippage if side == 1 else -slippage)

    # Calculate position size from AVAILABLE capital
    position_value = self.capital * self.config.position_size_pct
    shares = position_value / entry_price

    # CRITICAL: Deduct full position value + commission from capital
    total_cost = (shares * entry_price) + self.config.commission_per_trade
    self.capital -= total_cost  # <-- This line is often missing!

    # Store position
    self.positions[symbol] = Position(...)
```

### 2. Correct `_close_position()` Implementation
```python
def _close_position(self, symbol, price, time, bar_idx, reason):
    """Close position with proper capital accounting."""
    position = self.positions[symbol]

    # Apply slippage
    slippage = price * self.config.slippage_pct
    exit_price = price - (slippage if position.side == 1 else -slippage)

    commission = self.config.commission_per_trade

    # CRITICAL: Add sale proceeds (exit value - commission) to capital
    if position.side == 1:  # Long
        sale_proceeds = position.shares * exit_price - commission
    else:  # Short
        # Short P&L: entry - exit (profit when price falls)
        sale_proceeds = (2 * position.shares * position.entry_price) - \
                       (position.shares * exit_price) - commission

    self.capital += sale_proceeds  # <-- This line is often wrong!

    del self.positions[symbol]
```

### 3. Correct `_calculate_equity()` Implementation
```python
def _calculate_equity(self, current_price: float) -> float:
    """Calculate total equity = cash + market value of positions."""
    equity = self.capital  # Cash on hand

    for position in self.positions.values():
        if position.side == 1:  # Long
            market_value = position.shares * current_price
        else:  # Short
            # Short market value: 2*entry - current (profit when price falls)
            market_value = (2 * position.shares * position.entry_price) - \
                          (position.shares * current_price)
        equity += market_value

    return equity
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Only tracking P&L on close | Capital shows full value even with open positions | Must deduct on entry, add on exit |
| Using `capital = initial + sum(pnl)` | Ignores unrealized gains/losses | Equity must include position market value |
| Not applying slippage to entry/exit | Overstated returns | Apply slippage before calculating shares/proceeds |
| Adding position value to capital on close | Double-counts - position value already in equity | Add sale PROCEEDS, not position value |
| Short position P&L = (entry - exit) * shares | Wrong sign when price rises | Use 2*entry - exit formula for short market value |

## Final Parameters
```python
# BacktestConfig with proper defaults
@dataclass
class BacktestConfig:
    initial_capital: float = 100_000.0
    position_size_pct: float = 0.10      # 10% per position
    commission_per_trade: float = 1.0    # $1 per trade
    slippage_pct: float = 0.0005         # 0.05% slippage
    stop_loss_pct: float = 0.02          # 2% stop
    take_profit_pct: float = 0.04        # 4% TP
```

## Key Insights
- **The capital accounting bug is silent** - backtests run but produce garbage metrics
- **Equity must equal cash + market value** - at all times, not just on close
- **Short positions need special handling** - profit when price falls, loss when rises
- **Commission affects both entry AND exit** - double the impact of what you might expect
- **Slippage compounds with position size** - large positions have more slippage impact
- **Test with round trips** - open then close same position, capital should reflect P&L exactly

## Validation Check
After fixing, verify with this test:
```python
# After a round trip (buy then sell same shares):
# capital_after = capital_before + realized_pnl - 2*commission - slippage_cost
# If capital_after > capital_before + realistic_pnl, accounting is broken
```

## References
- CLAUDE.md guardrails: "Realistic backtests: Do not alter cash-flow logic without full audit"
- Standard brokerage margin accounting rules
- Walk-forward validation best practices
