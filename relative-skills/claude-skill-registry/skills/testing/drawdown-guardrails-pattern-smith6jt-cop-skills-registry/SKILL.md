---
name: drawdown-guardrails-pattern
description: "Consistent drawdown control pattern for trading systems - backtests, live trading, and training"
author: Claude Code
date: 2025-12-16
---

# Drawdown Guardrails Pattern - Research Notes

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2025-12-16 |
| **Goal** | Implement consistent drawdown controls across all trading system components |
| **Environment** | Python 3.10, PyTorch, custom trading system |
| **Status** | Success |

## Context
Trading systems need drawdown protection at multiple layers:
1. **Backtesting** - Avoid selecting high-drawdown strategies during model evaluation
2. **Live Trading** - Halt or reduce risk when equity drops
3. **Training** - Penalize models that learn high-return/high-drawdown behavior

Without consistent guardrails, a model might backtest well but blow up in production.

## Verified Workflow

### 1. Configuration (Single Source of Truth)
```python
# Define limits once, reference everywhere
MAX_DRAWDOWN_PCT = 0.15      # 15% - halt trading
DRAWDOWN_WARNING_PCT = 0.10  # 10% - reduce position sizes
DRAWDOWN_SIZING_SCALE = 0.5  # 50% position size in warning zone
```

### 2. Drawdown Tracking State
```python
@dataclass
class DrawdownState:
    peak_equity: float
    current_drawdown_pct: float = 0.0
    drawdown_warning_triggered: bool = False
    drawdown_halt_triggered: bool = False  # Once triggered, stays triggered

def update_drawdown_tracking(self, current_equity: float):
    """Update drawdown state - call after every equity calculation."""
    # Update peak (high water mark)
    if current_equity > self.peak_equity:
        self.peak_equity = current_equity

    # Calculate current drawdown
    if self.peak_equity > 0:
        self.current_drawdown_pct = (self.peak_equity - current_equity) / self.peak_equity

    # Update flags
    self.drawdown_warning_triggered = self.current_drawdown_pct >= DRAWDOWN_WARNING_PCT

    # Halt flag is sticky - once triggered, stays triggered until manual reset
    if self.current_drawdown_pct >= MAX_DRAWDOWN_PCT:
        self.drawdown_halt_triggered = True
```

### 3. Guardrail Check Function
```python
def check_drawdown_guardrails(self) -> Tuple[bool, str, float]:
    """
    Returns: (can_trade, reason, position_scale)
    """
    # Check halt condition
    if self.drawdown_halt_triggered:
        return False, f"max_drawdown_{self.current_drawdown_pct:.1%}", 0.0

    # Check warning condition
    if self.drawdown_warning_triggered:
        return True, f"drawdown_warning_{self.current_drawdown_pct:.1%}", DRAWDOWN_SIZING_SCALE

    # Normal operation
    return True, "ok", 1.0
```

### 4. Integration Points

#### Backtest Engine
```python
for bar_idx in range(start_idx, end_idx):
    # Calculate equity BEFORE new trades
    equity = self._calculate_equity(current_price)

    # Update drawdown tracking
    self._update_drawdown_tracking(equity)
    can_trade, reason, position_scale = self._check_drawdown_guardrails()

    # Only process signals if allowed
    if can_trade:
        self._process_signal(..., position_scale=position_scale)
    # Even if halted, existing positions can still exit via stop-loss/TP
```

#### Live Trading Loop
```python
while running:
    # Check drawdown before any trading
    can_trade, reason, position_scale = profit_tracker.check_trading_conditions(
        max_drawdown_pct=0.15
    )

    if not can_trade:
        logger.warning(f"TRADING HALTED: {reason}")
        # Allow exits but no new entries
        continue

    # Pass scale to trading function
    new_state = decide_and_trade(..., position_scale=position_scale)
```

#### Training Validation
```python
# Compute fitness with drawdown penalty
drawdown_penalty = config.drawdown_penalty_weight * max_drawdown
fitness_score = sharpe_ratio * max(0.0, 1.0 - drawdown_penalty)

# Early stopping on excessive drawdown
if max_drawdown > config.max_drawdown_threshold:
    print(f"DRAWDOWN EARLY STOP: {max_drawdown:.1%}")
    should_stop = True
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Only checking drawdown on trade entry | Positions can gap down overnight | Check on every bar/loop |
| Resetting halt flag when drawdown recovers | Creates "trading whipsaw" behavior | Halt should be sticky until manual reset |
| Using absolute dollar drawdown | Not comparable across account sizes | Always use percentage of peak |
| Linear position scaling 0-100% | Too aggressive reduction at small drawdowns | Use threshold-based (warning zone) |
| Not allowing exits when halted | Positions stuck, can't cut losses | Always allow stop-loss exits |
| Drawdown from initial capital | Misses profit drawdowns | Track from peak equity (high water mark) |

## Final Parameters
```python
# Recommended guardrail configuration
@dataclass
class DrawdownConfig:
    max_drawdown_pct: float = 0.15      # 15% - matches common hedge fund limits
    drawdown_warning_pct: float = 0.10  # 10% - early warning
    drawdown_sizing_scale: float = 0.5  # 50% in warning zone
    halt_on_max_drawdown: bool = True   # Hard stop at max
    drawdown_penalty_weight: float = 2.0  # Training penalty multiplier
```

## Key Insights
- **Drawdown from peak, not initial** - Track high water mark, not starting capital
- **Halt flag should be sticky** - Don't auto-resume trading after drawdown recovery
- **Allow exits even when halted** - Can still cut losses, just no new entries
- **Position scaling is gradual** - Warning zone reduces size, halt zone blocks entirely
- **Consistent across all layers** - Same 15% limit in backtest, live, and training
- **Training penalty prevents selection** - Models that drawdown heavily get lower fitness
- **Log when triggered** - Visibility into when guardrails activate

## Testing Checklist
```python
# Verify these scenarios:
1. [ ] Drawdown hits 10% -> position sizes reduced 50%
2. [ ] Drawdown hits 15% -> new entries blocked
3. [ ] Recovery to 5% drawdown -> halt flag STILL active (sticky)
4. [ ] Stop-loss orders execute even when halted
5. [ ] Training early-stops on 15%+ drawdown
6. [ ] Backtest metrics show drawdown correctly
```

## References
- CLAUDE.md: "Max drawdown trigger: 15%"
- Hedge fund risk management: 15-20% typical max drawdown limits
- Kelly criterion: Fractional Kelly (0.25-0.5x) to reduce drawdown
