---
name: multi-agent-integration
description: "Integrate Claude agents into training and live trading (v3.0). Trigger when: (1) setting up multi-agent training, (2) adding agent consultation to live trading, (3) configuring orchestrator, (4) understanding agent roles and safety mechanisms."
author: Claude Code
date: 2024-12-29
version: v3.0
---

# Multi-Agent Integration (v3.0)

## Overview

| Item | Details |
|------|---------|
| **Date** | 2024-12-29 |
| **Goal** | Integrate Claude agents for AI-assisted trading decisions |
| **Branch** | `feature/v3.0-multi-agent` |
| **New Code** | ~4,744 lines across 7 files |
| **Status** | Ready for integration |

## Agent Architecture

```
                    UnifiedOrchestrator (Opus)
                   (Synthesizes all recommendations)
                              |
        +---------------------+---------------------+
        |                     |                     |
   Training (5)          Trading (5)          Selection (4)
   - Hyperparameter      - Signal Analyst     - Symbol Scorer
   - Risk Analyst        - Risk Guardian      - Weight Optimizer
   - Reward Engineer     - Position Sizer     - Compatibility Auditor
   - Data Monitor        - Execution Timer    - Portfolio Coherence
   - Backtest Validator  - Exit Strategist
                              |
                    SharedAgentContext
                   (Thread-safe singleton)
                              |
                    AgentSafetyWrapper
                   (Bounds, rate limits, veto)
```

## Agent Roles by System

### Training Agents (5)

| Agent | Model | Interval | Purpose |
|-------|-------|----------|---------|
| **Hyperparameter Tuner** | Sonnet | 5 cycles | Optimizes LR, entropy coef, batch size |
| **Risk Analyst** | Sonnet | 3 cycles | Monitors drawdown, stability, overfitting |
| **Reward Engineer** | Sonnet | 10 cycles | Detects HOLD bias, reward collapse |
| **Data Monitor** | Haiku | 20 cycles | NaN/Inf detection, normalization drift |
| **Backtest Validator** | Sonnet | 15 cycles | Out-of-sample validation |

### Live Trading Agents (5)

| Agent | Model | Purpose |
|-------|-------|---------|
| **Signal Analyst** | Sonnet | Adjusts confidence (0.7-1.3x multiplier) |
| **Risk Guardian** | Sonnet | **VETO AUTHORITY** - enforces risk limits |
| **Position Sizer** | Haiku | Scales positions (0.3-2.0x) |
| **Execution Timer** | Haiku | MARKET vs LIMIT order selection |
| **Exit Strategist** | Sonnet | Stop/TP adjustments, exit timing |

### Selection Agents (4)

| Agent | Model | Purpose |
|-------|-------|---------|
| **Symbol Scorer** | Sonnet | Validates metrics, flags anomalies |
| **Weight Optimizer** | Sonnet | Adjusts scoring weights for regime |
| **Compatibility Auditor** | Haiku | Catches scoring errors |
| **Portfolio Coherence** | Sonnet | Validates diversity, suggests swaps |

## Safety Mechanisms

### Forbidden Actions (Agents can NEVER take)
- `bypass_all_gates`
- `disable_risk_controls`
- `unlimited_position`
- `ignore_drawdown`
- `force_margin_call`
- `delete_models`
- `modify_api_keys`

### Safety Bounds (All values clamped)

| Parameter | Bounds | Use Case |
|-----------|--------|----------|
| lr_multiplier | 0.1 - 3.0 | Training LR adjustment |
| entropy_multiplier | 0.1 - 5.0 | Exploration coefficient |
| position_scale | 0.3 - 2.0 | Position sizing |
| confidence_multiplier | 0.7 - 1.3 | Signal adjustment |
| stop_distance_pct | 0.5% - 15% | Stop-loss range |

### Rate Limiting

| Limit | Value |
|-------|-------|
| Max consultations/hour | 100 |
| Max actions/hour | 50 |
| Min interval between adjustments | 60 seconds |
| Max critical actions/day | 10 |

### Veto Authority
- **Risk Guardian** has veto power for safety-critical decisions
- Veto reasoning logged and auditable
- Orchestrator can override only with strong evidence

## Operating Modes

| Mode | Behavior |
|------|----------|
| **ADVISORY** (default) | Agents recommend, humans decide |
| **SUPERVISED** | Agents recommend with approval required |
| **AUTONOMOUS** | Agents execute recommendations |

## Integration: Training

### Configuration

```python
from alpaca_trading.training import MultiAgentTrainer, MultiAgentConfig

agent_config = MultiAgentConfig(
    # Enable/disable agents
    enable_hyperparameter_tuner=True,
    enable_risk_analyst=True,
    enable_reward_engineer=True,
    enable_data_monitor=False,  # Optional
    enable_backtest_validator=False,  # Expensive

    # Consultation intervals (validation cycles)
    hyperparam_interval=5,
    risk_interval=3,
    reward_interval=10,

    # Safety bounds
    max_lr_multiplier=2.0,
    min_lr_multiplier=0.1,

    # Cost control
    max_consultations_per_run=100,

    # Logging
    log_agent_responses=True,
)
```

### Usage

```python
# Create multi-agent trainer
trainer = MultiAgentTrainer(env, ppo_config, agent_config)

# Train with agent guidance
import asyncio
results = asyncio.run(trainer.train_with_guidance())

# Save agent logs
trainer.save_agent_logs("agent_logs.json")
```

## Integration: Live Trading

### Configuration

```python
from alpaca_trading.agents import (
    UnifiedOrchestrator,
    OrchestratorConfig,
    OrchestratorMode,
)

orchestrator = UnifiedOrchestrator(
    config=OrchestratorConfig(
        mode=OrchestratorMode.ADVISORY,  # Start safe
        enable_trading_agents=True,
        enable_selection_agents=False,
        min_consensus_for_action=0.66,  # 2/3 agreement
        require_unanimous_for_critical=True,
        max_total_consultations_per_hour=200,
    )
)
```

### Signal Evaluation

```python
# Consult Signal Analyst
analysis = await trading_agents.evaluate_signal(
    symbol="AAPL",
    direction=1,
    confidence=0.72,
    magnitude=0.015,
    regime="bull",
)

adjusted_confidence = analysis['adjusted_confidence']
recommendation = analysis['recommendation']  # PROCEED, REDUCE_SIZE, SKIP
```

### Gate Check with Risk Guardian

```python
# Risk Guardian has veto authority
risk_assessment = await trading_agents.evaluate_gates(
    symbol=symbol,
    gate_results=gate_results,
    win_rate=0.62,
    loss_streak=1,
    drawdown=0.032,
    exposure=0.45,
)

if risk_assessment['veto']:
    logger.warning(f"Risk Guardian veto: {risk_assessment['veto_reason']}")
    return False
```

### Position Sizing

```python
# Consult Position Sizer
sizing = await trading_agents.recommend_position_scale(
    signal_strength=0.75,
    confidence=0.72,
    volatility=0.24,
    drawdown=0.032,
    exposure=0.45,
    win_rate=0.62,
)

scale = sizing['scale_multiplier']  # 0.3 - 2.0
final_qty = base_qty * scale
```

## Shared Context

```python
from alpaca_trading.agents import get_shared_context

context = get_shared_context()

# Update portfolio state
context.update_portfolio_state(
    total_equity=105000,
    cash_available=45000,
    daily_pnl=320,
    current_drawdown=0.032,
    win_rate=0.625,
)

# Update market state
context.update_market_regime("bull", volatility=0.24)
context.update_trading_session("crypto_only")
```

## Cost Estimates

| Agent Type | Model | Est. Cost/Run |
|------------|-------|---------------|
| Orchestrator | Opus | ~$1.50 |
| Hyperparameter Tuner | Sonnet | ~$0.60 |
| Risk Analyst | Sonnet | ~$0.90 |
| Reward Engineer | Sonnet | ~$0.30 |
| Data Monitor | Haiku | ~$0.10 |
| **Total/Training Run** | - | **~$3.50** |

**Annual estimate:** ~$350-$700 (100 training runs)

## Requirements

- `ANTHROPIC_API_KEY` environment variable
- `anthropic` package (`pip install anthropic`)
- Optional: `nest_asyncio` for Colab compatibility

## Files Location

| File | Lines | Purpose |
|------|-------|---------|
| `alpaca_trading/agents/__init__.py` | 142 | Module exports |
| `alpaca_trading/agents/orchestrator.py` | 813 | Coordination |
| `alpaca_trading/agents/live_trading.py` | 761 | Trading agents |
| `alpaca_trading/agents/selection.py` | 677 | Selection agents |
| `alpaca_trading/agents/safety.py` | 373 | Safety guardrails |
| `alpaca_trading/agents/shared_context.py` | 490 | Shared state |
| `alpaca_trading/training/multi_agent.py` | 1,065 | Training agents |

## Rollout Strategy

| Phase | Description | Risk |
|-------|-------------|------|
| 1 | Merge branch, run tests | Low |
| 2 | Training integration (notebook) | Low |
| 3 | Live trading advisory mode | Low |
| 4 | Live trading autonomous mode | Medium |

**Recommendation:** Start with advisory mode for 2-4 weeks to validate agent quality before autonomous mode.

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Direct training loop modification | Breaks NativePPOTrainer | Use wrapper pattern instead |
| Synchronous agent calls | Blocks training loop | Use asyncio for parallel calls |
| No rate limiting | Runaway API costs | Always set max_consultations |
| No safety bounds | Agents recommended extreme values | Clamp all numeric outputs |
| Autonomous mode first | Untested agents made bad trades | Always start advisory |

## Key Principles

1. **Advisory by Default** - Start safe, validate before autonomous
2. **Wrapper Pattern** - Don't modify core training/trading code
3. **Consensus Required** - 2/3 agreement for action, unanimous for critical
4. **Veto Authority** - Risk agents can block unsafe actions
5. **Bounds Enforcement** - All numeric values clamped to safe ranges
6. **Rate Limiting** - Prevent API cost explosion
7. **Full Audit Trail** - Every decision logged with reasoning

## References

- `docs/reference/AI_AGENT_REFERENCE.md` - Comprehensive guide
- `examples/multi_agent_training_example.py` - Working example
- Branch: `feature/v3.0-multi-agent`
