---
name: btc-trading-bot
description: |
  Bitcoin trading simulation with technical analysis (EMA/RSI/Bollinger), Monte Carlo projections, and Telegram alerts. Cambodian market focus (USD/KHR 4050).
  
  TRIGGERS: BTC backtesting, indicator calculations, Fear & Greed integration, crypto strategy development, CoinGecko/Alternative.me APIs, portfolio simulation, trailing stop optimization, Sharpe/drawdown metrics.
  
  ENTRY POINTS: btc_trader.py (365d backtest), btc_simulation.py (60d Monte Carlo), backtest_runner.py (advanced metrics).
---

# BTC Trading Bot

## Architecture

```
btc_trader.py ──────────────────► Telegram / Console
     │                              ▲
     │ imports                      │
     ▼                              │
backtest_runner.py ─────────────────┘
     
btc_simulation.py (self-contained, duplicates core functions)
```

**Critical**: `btc_simulation.py` duplicates functions. Refactor target.

## Execution

```bash
python btc_trader.py        # 365d backtest → Telegram
python btc_simulation.py    # 60d GBM Monte Carlo
python backtest_runner.py   # Sharpe, drawdown, win rate
```

```bash
# Optional Telegram (falls back to stdout)
export TELEGRAM_BOT_TOKEN="..."
export TELEGRAM_CHAT_ID="..."
```

## Strategy Matrix

| Condition | Elite (btc_trader) | Pro (btc_simulation) |
|-----------|-------------------|---------------------|
| Trend Entry | EMA12>26 ∧ RSI∈[50,70] ∧ FNG<80 | EMA12>26 ∧ RSI∈[50,75] |
| Contrarian | Price<BB_lower ∧ RSI<35 ∧ FNG<25 | — |
| Exit: Reversal | EMA12<26 | EMA12<26 |
| Exit: Blow-off | Price>BB_upper ∧ RSI>75 ∧ FNG>80 | — |
| Exit: Stop | 5% trailing | 5% trailing |

**⚠️ 5% trailing stop is dangerously tight for crypto.** BTC routinely swings 3-5% intraday. See [ATR-based stop](#dynamic-trailing-stop).

## Indicators

```python
# All calculations in calculate_indicators(df)
EMA_12  = Close.ewm(span=12, adjust=False).mean()
EMA_26  = Close.ewm(span=26, adjust=False).mean()
RSI_14  = 100 - (100 / (1 + avg_gain / avg_loss.replace(0, ε)))  # ε prevents div/0
BB_MID  = Close.rolling(20).mean()
BB_STD  = Close.rolling(20).std()
BB_UP   = BB_MID + 2σ
BB_LOW  = BB_MID - 2σ
```

**Warmup period**: First 26 rows are garbage (NaN propagation). Drop or backfill.

## Data Sources

| API | Endpoint | Rate Limit | Timeout |
|-----|----------|------------|---------|
| CoinGecko | `/coins/bitcoin/market_chart?vs_currency=usd&days=N` | ~30/min | 10s |
| Alternative.me | `/fng/?limit=N` | Generous | 10s |

**FNG Fallback**: Silently returns 50 on failure. **This masks API issues.** Add logging.

```python
# Proper FNG fetch with warning
try:
    fng_data = requests.get(url, timeout=10).json()
except Exception as e:
    logging.warning(f"FNG API failed: {e}, defaulting to 50")
    return pd.DataFrame({'Date': dates, 'FNG_Value': 50})
```

## Critical Bugs

### 1. Ledger Parser Format Mismatch
`backtest_runner.py:47-60` regex expects Elite format, breaks on Pro.

```python
# Elite: "2025-01-15: BUY at $42,500.00"
# Pro:   "Day 0 (2025-01-01): BUY at $42,500.00"

# FIX: Universal parser
import re
def parse_trade(entry: str) -> dict:
    patterns = [
        r'(\d{4}-\d{2}-\d{2}): (BUY|SELL) at \$([\d,]+\.?\d*)',           # Elite
        r'Day \d+ \((\d{4}-\d{2}-\d{2})\): (BUY|SELL) at \$([\d,]+\.?\d*)' # Pro
    ]
    for p in patterns:
        if m := re.match(p, entry):
            return {'date': m[1], 'action': m[2], 'price': float(m[3].replace(',', ''))}
    raise ValueError(f"Unknown format: {entry}")
```

### 2. Unrealized P&L at Backtest End
Open positions must be marked-to-market at final close price.

```python
# End of run_elite_strategy()
if position_open:
    unrealized = btc_held * df.iloc[-1]['Close']
    portfolio_value = cash + unrealized
```

### 3. Timezone Inconsistency
CoinGecko returns UTC timestamps. FNG returns Unix timestamps. Merge carefully.

```python
# Always normalize to UTC date
df['Date'] = pd.to_datetime(df['Date']).dt.tz_localize(None).dt.normalize()
```

## Dynamic Trailing Stop

Replace fixed 5% with ATR-based volatility adjustment:

```python
def calculate_atr(df: pd.DataFrame, period: int = 14) -> pd.Series:
    tr = pd.concat([
        df['High'] - df['Low'],
        (df['High'] - df['Close'].shift()).abs(),
        (df['Low'] - df['Close'].shift()).abs()
    ], axis=1).max(axis=1)
    return tr.rolling(period).mean()

# Dynamic stop: 2× ATR below entry (or highest since entry)
stop_price = highest_since_entry - (2 * current_atr)
```

**Note**: CoinGecko `/market_chart` only returns Close. For ATR, use `/ohlc` endpoint or exchange API.

## Monte Carlo Assumptions

`btc_simulation.py` uses Geometric Brownian Motion:

```
dS = μSdt + σSdW
```

**Limitations for crypto:**
- Assumes log-normal returns (BTC has fat tails, kurtosis ~6-10)
- Ignores regime shifts (bull/bear transitions)
- Calibrates μ,σ from 60d history (recency bias)

**Improvement**: Use GARCH(1,1) for volatility clustering or regime-switching model.

## Metrics Reference

```python
# Sharpe Ratio (annualized, daily returns)
sharpe = (mean_daily_return / std_daily_return) * sqrt(365)

# Max Drawdown
peak = running_max(portfolio_values)
drawdown = (peak - current) / peak
max_dd = max(drawdown)

# Win Rate
wins = trades.where(pnl > 0).count()
win_rate = wins / total_trades

# Profit Factor
gross_profit = sum(pnl.where(pnl > 0))
gross_loss = abs(sum(pnl.where(pnl < 0)))
profit_factor = gross_profit / gross_loss
```

## Cambodian Market

```python
USD_KHR = 4050

def format_khr(usd: float) -> str:
    return f"៛{usd * USD_KHR:,.0f}"

# Telegram report excerpt
msg = f"""
💰 Portfolio: ${value:,.2f}
🇰🇭 KHR: {format_khr(value)}
"""
```

## Code Patterns

### Safe RSI
```python
avg_loss = loss.rolling(14).mean().replace(0, np.finfo(float).eps)
```

### Timezone-Safe Datetime
```python
from datetime import datetime, timezone
now = datetime.now(timezone.utc)
```

### API with Retry
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, max=10))
def fetch_with_retry(url: str) -> dict:
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    return r.json()
```

## Backtesting Pitfalls

| Pitfall | Status | Fix |
|---------|--------|-----|
| Lookahead bias | ✅ OK | Uses `.shift()` for signals |
| Survivorship bias | ✅ N/A | Single asset |
| Slippage/fees | ❌ Missing | Add 0.1% per trade |
| Position sizing | ❌ 100% always | Implement Kelly or fixed-fraction |
| Out-of-sample | ❌ Missing | Split train/test periods |

```python
# Add transaction cost
SLIPPAGE = 0.001  # 0.1%
def execute_buy(price, capital):
    effective_price = price * (1 + SLIPPAGE)
    return capital / effective_price

def execute_sell(price, btc_held):
    effective_price = price * (1 - SLIPPAGE)
    return btc_held * effective_price
```

## File Reference

| File | Read When |
|------|-----------|
| [references/strategies.md](references/strategies.md) | Strategy modification, threshold tuning |
| [references/indicators.md](references/indicators.md) | Adding new indicators, formula verification |
| [references/apis.md](references/apis.md) | API debugging, response schema lookup |
| [references/PRODUCTION_ARCHITECTURE.md](references/PRODUCTION_ARCHITECTURE.md) | **Going live**: Full system design, deployment, safety |
| [scripts/utils.py](scripts/utils.py) | Data validation, metrics calculation, ledger parsing |

## Quick Fixes Checklist

- [ ] Add FNG warning log on API failure
- [ ] Fix ledger parser for both formats
- [ ] Extract shared module from btc_trader/btc_simulation
- [ ] Add config.yaml for thresholds
- [ ] Implement ATR-based trailing stop
- [ ] Add slippage to backtester
- [ ] Split backtest into train/validation periods

---

## Production Migration

See [references/PRODUCTION_ARCHITECTURE.md](references/PRODUCTION_ARCHITECTURE.md) for complete system design.

### TL;DR Architecture

```
DataService ──► StrategyEngine ──► ExecutorService ──► Exchange
     │               │                    │
     └───────────────┴────────────────────┴──► PostgreSQL
                                               │
                     RiskManager (Watchdog) ◄──┘
                           │
                     TelegramControl
```

### Key Technologies

| Component | Technology |
|-----------|------------|
| Exchange API | `ccxt` (107 exchanges) |
| WebSocket | `ccxt.pro` |
| Database | PostgreSQL |
| Control | Telegram bidirectional |
| Deployment | VPS Singapore + systemd |

### Safety-First Principles

1. **Testnet first** — `exchange.set_sandbox_mode(True)`
2. **Paper trading mode** — Toggle without code changes
3. **Kill switch** — Independent watchdog process
4. **Position limits** — Max 25% capital per trade
5. **Daily loss limit** — Auto-stop at 5% daily loss
6. **Heartbeat monitoring** — Alert if bot stops responding

### Migration Timeline

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Refactor | 2 weeks | Modular codebase + tests |
| Exchange | 2 weeks | ccxt integration + testnet |
| Real-time | 1 week | WebSocket data feed |
| Safety | 1 week | Risk manager + kill switch |
| Control | 2 weeks | Telegram + dashboard |
| Deploy | 1 week | VPS + monitoring |
| Live | Ongoing | Start with $100 |

### Minimum Viable Production

```bash
pip install ccxt python-telegram-bot pyyaml asyncpg
```

```python
# Simplest live trading loop
async def main():
    exchange = ccxt.binance({'apiKey': KEY, 'secret': SECRET})
    exchange.set_sandbox_mode(True)  # TESTNET!
    
    while True:
        df = await fetch_data()
        signal = strategy.generate_signal(df, position)
        
        if signal.is_entry and risk.check_trade():
            await executor.execute_market_order('buy', quantity)
            telegram.send(f"BUY executed at {price}")
            
        await asyncio.sleep(3600)  # Hourly
```

### Cost

- Infrastructure: ~$25/month
- Trading fees: 0.1% per trade
- Start capital: $100 minimum recommended
