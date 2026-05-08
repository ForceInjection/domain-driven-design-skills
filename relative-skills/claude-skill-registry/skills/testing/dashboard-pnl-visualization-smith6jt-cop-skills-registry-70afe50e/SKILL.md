---
name: dashboard-pnl-visualization
description: "Trading dashboard P&L visualization with profit tracker integration, win-rate overlays, R-multiples, and configurable settings"
author: Claude Code
date: 2025-12-13
---

# dashboard-pnl-visualization - Research Notes

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2025-12-13 |
| **Goal** | Enhance trading dashboard with comprehensive P&L tracking, win-rate overlays from profit tracker, and R-multiple position visualization |
| **Environment** | Python 3.10, matplotlib, alpaca-py, Alpaca Trading API |
| **Status** | Success |

## Context
Trading dashboards often show only gross P&L without breaking down realized vs unrealized, cost coverage, or win-rate context. This skill documents patterns for integrating profit tracker data into dashboard visualizations.

## Verified Workflow

### 1. DashboardConfig Dataclass
Create a configurable runtime settings system:

```python
from dataclasses import dataclass, field
from typing import List
import json
from pathlib import Path

@dataclass
class DashboardConfig:
    """Runtime configuration for the monitoring dashboard."""
    symbols: List[str] = field(default_factory=lambda: ["SPY", "QQQ", "AAPL"])
    lookback_days: int = 30
    interval_seconds: int = 60
    output_dir: str = "dashboards"
    cost_data: float = 3.33        # Daily data cost
    cost_software: float = 6.67    # Daily software cost
    risk_limit_pct: float = 10.0   # Portfolio risk limit
    profit_log_dir: str = "logs/live"
    save_latest: bool = True

    @classmethod
    def from_json(cls, path: str) -> "DashboardConfig":
        if not path or not Path(path).exists():
            return cls()
        return cls(**json.loads(Path(path).read_text()))
```

### 2. Broker Equity History Integration
Fetch real portfolio equity data from Alpaca:

```python
def get_equity_history(
    self,
    period: str = "1M",    # '1D', '1W', '1M', '3M', '1A'
    timeframe: str = "1D", # '1Min', '5Min', '15Min', '1H', '1D'
) -> List[Dict[str, Any]]:
    """Return historical equity curve from the broker."""
    from alpaca.trading.requests import GetPortfolioHistoryRequest

    request = GetPortfolioHistoryRequest(period=period, timeframe=timeframe)
    history = self._client.get_portfolio_history(request)

    if hasattr(history, "equity") and hasattr(history, "timestamp"):
        return [
            {"timestamp": ts, "value": eq}
            for ts, eq in zip(history.timestamp, history.equity)
        ]
    return []
```

### 3. Win-Rate Overlay from Profit Tracker
Load profit summary for live metrics overlay:

```python
def load_profit_summary(log_dir: str) -> Dict:
    """Load profit tracker summary for win-rate overlays."""
    path = Path(log_dir)
    summary_files = sorted(path.glob("*/profit_summary.json"))
    if not summary_files:
        return {}

    with summary_files[-1].open() as f:
        summary = json.load(f)

    trades = summary.get("trades", [])
    pnls = [t.get("pnl", 0.0) for t in trades]
    wins = [p for p in pnls if p > 0]

    # Calculate loss streak
    loss_streak = 0
    for pnl in reversed(pnls):
        if pnl <= 0:
            loss_streak += 1
        else:
            break

    return {
        "win_rate": len(wins) / len(pnls) if pnls else 0.0,
        "loss_streak": loss_streak,
        "trade_count": len(pnls),
    }
```

### 4. Realized vs Unrealized P&L Split

```python
def get_pnl_breakdown(broker, cfg, profit_overlay, open_pnl=0.0) -> dict:
    """Get P&L breakdown with realized/unrealized split."""
    account = broker.get_account()
    equity = float(account['equity'])
    last_equity = float(account.get('last_equity', equity))

    daily_pnl = equity - last_equity
    unrealized_pnl = float(open_pnl)
    realized_pnl = daily_pnl - unrealized_pnl

    breakdown = {
        'gross_pnl': daily_pnl,
        'unrealized_pnl': unrealized_pnl,
        'realized_pnl': realized_pnl,
        'data_cost': cfg.cost_data,
        'software_cost': cfg.cost_software,
    }
    breakdown['net_pnl'] = breakdown['gross_pnl'] - cfg.cost_data - cfg.cost_software

    # Add win-rate overlay
    if profit_overlay:
        breakdown['win_rate'] = profit_overlay.get('win_rate')
        breakdown['loss_streak'] = profit_overlay.get('loss_streak')

    return breakdown
```

### 5. R-Multiple Display for Positions

```python
def calculate_r_multiple(entry_price, current_price, stop_price, side):
    """Calculate R-multiple for position risk-reward."""
    if not stop_price:
        return None

    if side != 'short':
        risk_per_share = entry_price - stop_price
        profit_per_share = current_price - entry_price
    else:
        risk_per_share = stop_price - entry_price
        profit_per_share = entry_price - current_price

    if risk_per_share <= 0:
        return None

    return profit_per_share / risk_per_share

# Color coding for R-multiples
def get_r_color(r_multiple):
    if r_multiple is None:
        return 'gray'
    elif r_multiple >= 2:
        return 'darkgreen'  # Excellent
    elif r_multiple >= 1:
        return 'green'      # Good
    else:
        return 'orange'     # Below target
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Using `account.equity - account.last_equity` directly | Doesn't separate realized from unrealized | Pass `open_pnl` from position calculations |
| Hardcoding cost values | Different users have different infrastructure costs | Use DashboardConfig dataclass |
| Reading profit_summary from fixed path | Path varies by session date | Use glob to find most recent summary |
| Displaying R-multiple without stop price | Division by zero / meaningless value | Return None and show "--" in display |

## Final Parameters

```python
# CLI arguments for dashboard
parser.add_argument('--config', type=str, help='JSON config path')
parser.add_argument('--symbols', type=str, help='Comma-separated symbols')
parser.add_argument('--lookback-days', type=int, default=30)
parser.add_argument('--data-cost', type=float, default=3.33)
parser.add_argument('--software-cost', type=float, default=6.67)
parser.add_argument('--risk-limit', type=float, default=10.0)
parser.add_argument('--profit-log-dir', type=str, default='logs/live')
```

## Key Insights
- Realized/unrealized split requires tracking open position P&L separately
- Win-rate overlays provide crucial context for daily P&L interpretation
- R-multiples only meaningful when stop prices are set
- Cost coverage percentage helps evaluate if trading covers infrastructure costs
- JSON config files allow per-environment customization without code changes
- Profit tracker summaries should be written with timestamp directories for history

## References
- `alpaca_trading/broker.py` - `get_equity_history()` method
- `alpaca_trading/visualization/dashboard.py` - R-multiple rendering
- `scripts/monitor_dashboard.py` - Full implementation
- `docs/dashboard_improvements.md` - Feature documentation
