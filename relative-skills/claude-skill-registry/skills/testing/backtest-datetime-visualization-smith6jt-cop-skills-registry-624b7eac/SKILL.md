---
name: backtest-datetime-visualization
description: "Converting backtest visualizations from bar indices/timesteps to actual datetime axes for clearer time context"
author: Claude Code
date: 2025-12-13
---

# backtest-datetime-visualization - Research Notes

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2025-12-13 |
| **Goal** | Convert backtest result visualizations from using bar indices (0, 1, 2...) to actual datetime values for equity curves, drawdowns, and trade distributions |
| **Environment** | Python 3.10, matplotlib, pandas, Jupyter notebooks |
| **Status** | Success |

## Context
Backtest visualizations often use bar indices or timestep numbers on the x-axis, which makes it difficult to correlate results with actual market periods. Converting to datetime axes provides:
- Clear understanding of when drawdowns occurred
- Correlation with known market events
- Proper time-proportional spacing

## Verified Workflow

### 1. Equity Curve with DateTime Index
When equity_curve is a pandas Series with DatetimeIndex:

```python
# equity_series is pd.Series with DatetimeIndex
ax.plot(equity_series.index, equity_series.values, 'b-', label='Strategy')
ax.set_xlabel('Date')
ax.tick_params(axis='x', rotation=45)  # Rotate for readability
```

### 2. Drawdown Plot with Timestamps

```python
# Extract timestamps from equity series
equity = equity_series.values
timestamps = equity_series.index  # DatetimeIndex
running_max = np.maximum.accumulate(equity)
drawdown = (running_max - equity) / running_max * 100

# Use timestamps for x-axis
ax.fill_between(timestamps, 0, drawdown, color='red', alpha=0.5)
ax.set_xlabel('Date')
ax.tick_params(axis='x', rotation=45)
ax.invert_yaxis()  # Drawdown goes down
```

### 3. Trade P&L with Entry Times
For trade distributions, use entry_time from TradeRecord:

```python
if len(result.trades) > 0:
    trade_pnls = [t.pnl for t in result.trades]
    trade_times = [t.entry_time for t in result.trades]

    # Use stem plot for datetime x-axis (more robust than bar)
    markerline, stemlines, baseline = ax.stem(trade_times, trade_pnls, basefmt='k-')

    # Color stems based on profit/loss
    for stem, pnl in zip(stemlines, trade_pnls):
        stem.set_color('green' if pnl > 0 else 'red')
        stem.set_alpha(0.7)

    ax.set_xlabel('Date')
    ax.tick_params(axis='x', rotation=45)
```

### 4. Bar Charts with DateTime (Alternative)
If you must use bar charts with datetime:

```python
import matplotlib.dates as mdates

# Convert datetime to matplotlib date numbers
trade_dates = mdates.date2num(trade_times)
width = 0.5  # Width in days

ax.bar(trade_dates, trade_pnls, width=width, color=colors)
ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d'))
ax.xaxis.set_major_locator(mdates.AutoDateLocator())
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| `ax.bar(trade_times, trade_pnls)` directly | Width parameter issues with datetime objects | Use `stem` plot or convert to matplotlib date numbers |
| `range(len(drawdown))` for x-axis | Loses all time context | Always use `equity_series.index` |
| Not rotating x-axis labels | Dates overlap and become unreadable | Add `ax.tick_params(axis='x', rotation=45)` |
| Using `plt.xticks(rotation=45)` | Affects all subplots | Use `ax.tick_params()` for specific axis |

## Final Parameters

```python
# Standard pattern for backtest visualization
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Equity curve
ax = axes[0, 0]
ax.plot(equity_series.index, equity_series.values)
ax.set_xlabel('Date')
ax.tick_params(axis='x', rotation=45)

# Drawdown
ax = axes[0, 1]
ax.fill_between(equity_series.index, 0, drawdown)
ax.set_xlabel('Date')
ax.tick_params(axis='x', rotation=45)

# Trade P&L (use stem for datetime compatibility)
ax = axes[1, 0]
ax.stem(trade_times, trade_pnls, basefmt='k-')
ax.set_xlabel('Date')
ax.tick_params(axis='x', rotation=45)

plt.tight_layout()  # Prevent label overlap
```

## Key Insights
- `plt.stem()` handles datetime x-values better than `plt.bar()` without conversion
- Always call `plt.tight_layout()` after rotating labels to prevent clipping
- Backtest DataFrames should use DatetimeIndex, not integer index
- TradeRecord objects should store `entry_time` as datetime, not bar index
- For long time ranges, consider using `mdates.MonthLocator()` or `YearLocator()`
- The observation window plots (100-step windows) should keep "Time Step" labels since they represent relative position, not calendar time

## Data Requirements
Ensure your backtest engine stores proper timestamps:

```python
@dataclass
class TradeRecord:
    symbol: str
    entry_time: datetime  # Not int!
    exit_time: Optional[datetime]
    entry_price: float
    exit_price: Optional[float]
    pnl: float
```

## References
- `alpaca_trading/backtest/engine.py` - TradeRecord with entry_time
- `notebooks/develop_branch_testing.ipynb` - Visualization examples
- matplotlib.dates documentation for advanced date formatting
