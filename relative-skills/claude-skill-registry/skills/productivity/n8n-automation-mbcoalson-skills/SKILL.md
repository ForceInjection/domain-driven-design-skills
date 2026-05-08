---
name: n8n-automation
description: n8n workflow automation for building analytics including SkySpark multi-agent systems, FastAPI tool servers, workflow orchestration, and automated building system alert triage
---

# n8n Automation Skill

This skill provides expertise in building automation workflows using n8n, specifically focused on SkySpark integration and multi-agent systems for building analytics.

## Core Capabilities

### SkySpark Multi-Agent Architecture
- Gatekeeper agent with specialist routing
- Automated spark triage and prioritization
- HVAC specialist for mechanical system analysis
- Energy calculation agent for savings estimates
- Automated report generation workflows

### n8n Workflow Development
- REST API integrations with building systems
- Multi-agent coordination patterns
- Error handling and logging strategies
- Scheduled automation and notifications

### SkySpark Integration
- Haystack REST API connectivity
- ZINC and JSON data format handling
- Spark and trend data extraction
- Authentication and security patterns

## Available Scripts
- scripts/fastapi_tool_server.py: Template for FastAPI tool servers
- scripts/n8n_workflow_templates/: Common workflow patterns
- scripts/skyspark_mock_data.py: Generate test data for development

## Reference Materials
- 
eferences/multi_agent_patterns.md: Proven multi-agent architectures
- 
eferences/skyspark_api.md: SkySpark Haystack API documentation
- 
eferences/n8n_best_practices.md: Workflow development guidelines
- 
eferences/roadmap.md: 5-phase project roadmap (Foundation → Production)

## Asset Templates
- ssets/workflow_exports/: n8n workflow export files
- ssets/api_schemas/: OpenAPI schemas for tool servers
- ssets/mock_data/: Sample SkySpark data for testing

## Current Project: SkySpark Multi-Agent System

### 5-Phase Roadmap
1. **Foundation**: FastAPI tool server + basic agent interaction
2. **Mock Integration**: Agent logic with simulated SkySpark data
3. **Real SkySpark**: Live Haystack API connection
4. **Multi-Agent**: Full specialist coordination
5. **Production**: Error handling, scheduling, notifications

### Multi-Agent Pattern
`
User Request → Gatekeeper Agent (routes by intent)
                ↓
    ┌───────────┼───────────┬──────────────┐
    ↓           ↓           ↓              ↓
Triage      HVAC        Energy         Report
Agent       Specialist  Calc Agent     Generator
`

## Agent Architecture for Future RL Orchestration

### Stateless Agent Design Principles
All SkySpark agents should be designed with future dynamic orchestration in mind:

**Statelessness Requirements:**
- Agents receive complete diagnostic context as input (no persistent memory)
- All necessary context passed in, new state returned out
- Enables any agent to follow any agent (maximum routing flexibility)
- Simplifies debugging and testing

**Standardized I/O Schema:**

Input: `DiagnosticState` object containing:
- `alert_context`: Current alert/issue details (Haystack tags, spark data)
- `prior_actions`: Array of prior agent outputs/reasoning
- `available_tools`: List of tool endpoints and capabilities
- `token_budget_remaining`: Tokens available for continued diagnosis
- `confidence_score`: Current diagnostic confidence (0.0-1.0)
- `metadata`: Alert severity, facility info, timestamps

Output: `AgentResponse` object containing:
- `updated_state`: Refreshed DiagnosticState with new findings
- `agent_findings`: This agent's analysis, calculations, or actions
- `recommended_next_agents`: Suggested routing (even if not used in Phase 0-1)
- `token_cost`: Tokens consumed by this agent call
- `confidence_delta`: Change in diagnostic confidence (+/- 0.0-1.0)
- `actions_taken`: List of tools called or queries executed

**Role-Based Architecture:**
Separate agent identity (role prompts) from action logic:

*Tool-Use Agents:*
- `SkySpark_Query_Agent`: Execute Axon queries against SkySpark database
- `Python_Analysis_Agent`: Statistical analysis, calculations, trending
- `File_Reader_Agent`: Parse equipment specs, CSV logs, JSON configs
- `Weather_Data_Agent`: Fetch external weather data via API
- `Documentation_Agent`: Search equipment manuals, ASHRAE standards

*Reasoning Agents:*
- `Diagnostic_Planner_Agent`: Decompose complex issues into sub-diagnostics
- `Root_Cause_Analyzer_Agent`: Synthesize data to identify probable causes
- `Validation_Agent`: Verify diagnostic logic and calculations
- `Reflection_Agent`: Assess diagnostic trajectory, propose refinements
- `Summary_Agent`: Generate concise diagnostic reports
- `Resolution_Agent`: Recommend corrective actions
- `Modification_Agent`: Correct errors in prior reasoning

### Orchestration Evolution Roadmap

**Phase 0-1: Static n8n Workflows (Current)**
- Hardcoded agent routing via n8n nodes is acceptable
- BUT design workflows to call centralized routing functions
- Log every routing decision with full context
- Focus: Get agents working with standardized I/O

**Phase 2-3: Rule-Based Orchestrator**
- Implement `agent_router` function (Python/FastAPI endpoint)
- Route based on: alert type/severity, confidence score, prior sequence
- Manually tune rules based on logged diagnostic patterns
- A/B test against static workflows
- Focus: Data-driven routing without ML complexity

**Phase 4-5: RL-Based Orchestrator**
- Replace rule-based router with learned policy
- Train on logged diagnostic trajectories (minimum 200 episodes)
- Optimize for: `R = accuracy - λ × token_cost - β × time_penalty`
- Enable online learning from production outcomes
- Focus: Continuous optimization and adaptation

### Instrumentation & Logging Requirements

**Critical: Start logging from Day 1, even with static workflows**

Log every diagnostic episode with schema:
```json
{
  "episode_id": "alert_123456_2025-12-02",
  "facility_name": "Building XYZ",
  "alert_context": {
    "alert_type": "High AHU static pressure",
    "severity": "warning",
    "haystack_refs": [...],
    "triggered_at": "2025-12-02T10:15:00Z"
  },
  "agent_sequence": [
    {
      "timestamp": "2025-12-02T10:30:00Z",
      "agent_type": "SkySpark_Query_Agent",
      "input_state": {...},
      "output_state": {...},
      "tokens_used": 1500,
      "duration_ms": 3400,
      "tools_called": ["read_trends", "eval_axon"]
    },
    ...
  ],
  "final_outcome": {
    "diagnostic_correct": true,
    "root_cause_identified": "Filter 80% loaded",
    "resolution_actions": ["Schedule filter replacement"],
    "total_tokens": 8500,
    "total_duration_ms": 15200,
    "human_intervention_required": false,
    "human_feedback": "Diagnosis accurate, action appropriate"
  }
}
```

**Storage Strategy:**
- Store in n8n database OR dedicated TimescaleDB
- Retain minimum 200 episodes per alert type for RL training
- Enable easy export for offline analysis and model training
- Version control state schemas alongside agents

**What to Log:**
- Complete agent call sequence per diagnostic episode
- Full input/output states at each step
- Token consumption per agent (measure via API or estimate)
- Human validation/corrections (critical for reward labels)
- Final diagnostic outcome and resolution effectiveness
- Time to resolution relative to SLA thresholds

### Reward Function Design

**Preliminary specification for future RL training:**

```
R = accuracy_score - λ × token_cost - β × time_penalty
```

Where:
- `accuracy_score ∈ [0, 1]` - Validated against human review OR resolution outcome
- `token_cost = tokens_used / max_token_budget` - Normalized efficiency metric
- `time_penalty = max(0, (time_to_resolve / sla_threshold) - 1)` - Timeliness factor
- `λ = 0.1` - Efficiency weight (tunable based on production costs)
- `β = 0.05` - Timeliness weight (varies by alert severity)

**Accuracy Validation:**
- Binary: Did diagnostic identify correct root cause? (0 or 1)
- Graduated: Partial credit for narrowing to subsystem (0.0-1.0 scale)
- Ground truth: FM confirmation or system behavior post-resolution

**Efficiency Considerations:**
- Critical alerts: Prioritize accuracy over token cost (λ → 0)
- Informational alerts: Prioritize efficiency (λ → 0.2)
- Balance prevents both over-analysis and premature conclusions

**Timeliness Thresholds:**
- Critical: 15 min SLA → high β penalty if exceeded
- Warning: 60 min SLA → moderate β penalty
- Info: 4 hour SLA → minimal β penalty

### SkySpark Agent Taxonomy

Agents aligned with Puppeteer research categories:

**Tool-Use Agents (External data access):**
1. SkySpark_Query_Agent - Axon query execution
2. Python_Analysis_Agent - Statistical calculations, trending
3. File_Reader_Agent - Equipment specs, logs, configs
4. Weather_Data_Agent - External weather APIs
5. Documentation_Agent - Manuals, standards, knowledge base

**Reasoning Agents (Internal cognition):**
1. Diagnostic_Planner_Agent - Task decomposition
2. Root_Cause_Analyzer_Agent - Data synthesis
3. Validation_Agent - Logic verification
4. Reflection_Agent - Meta-reasoning
5. Summary_Agent - Report generation
6. Resolution_Agent - Action recommendation
7. Modification_Agent - Error correction

### Critical Don'ts

**Avoid these pitfalls:**
- ❌ Don't jump to RL before having logged data (minimum 200 episodes)
- ❌ Don't hardcode agent sequences into prompts (keep routing external)
- ❌ Don't skip instrumentation "for now" (you'll never add it later)
- ❌ Don't design agents that assume specific predecessors
- ❌ Don't sacrifice debuggability for sophistication
- ❌ Don't optimize prematurely (get working system first)
- ❌ Don't force-fit RL where rules work fine

**Do these instead:**
- ✅ Keep current n8n approach for Phase 0-1 (it's pragmatic)
- ✅ Design agents with standardized I/O from day 1
- ✅ Start logging immediately, even with static workflows
- ✅ Validate every agent output initially (build ground truth dataset)
- ✅ Build tooling to visualize agent sequences (aid debugging)
- ✅ Document reward function assumptions (evolve with data)
- ✅ Plan human override mechanisms (safety net)

### Success Metrics by Phase

**Phase 1 (Static n8n + Logging):**
- [ ] 5+ agents implemented with standardized I/O
- [ ] 100% of diagnostic episodes logged with schema
- [ ] Static workflow resolves 70%+ of test alerts correctly
- [ ] Average 8-12k tokens per diagnostic episode

**Phase 2 (Rule-Based Router):**
- [ ] Rule-based router handles 80%+ of alert types
- [ ] 10% reduction in average tokens vs. static workflow
- [ ] Diagnostic accuracy maintained or improved (≥70%)
- [ ] Routing decisions explainable to FM stakeholders

**Phase 3 (RL Orchestrator):**
- [ ] RL policy trained on 200+ episodes
- [ ] Matches or exceeds rule-based accuracy
- [ ] 20%+ token reduction vs. static baseline
- [ ] Cyclic reasoning patterns emerge for complex diagnostics

**Phase 4 (Production RL):**
- [ ] Online learning maintains 90%+ diagnostic accuracy
- [ ] 30%+ token reduction vs. baseline
- [ ] Handles novel alert types through adaptation
- [ ] Human intervention required <10% of cases

### Integration with Existing Architecture

**Compatible with current project structure:**
- Project instructions: `Project-Specific-Instructions/SkySpark-n8n-Workflow.md`
- n8n workflows: `n8n/`
- Agent design aligns with FastAPI tool server architecture
- State schema accommodates SkySpark Haystack data model
- Reward function maps to ComEd program requirements

**Backward Compatibility:**
- Phase 0-1 static workflows remain fully functional
- Standardized I/O is additive, not breaking
- Logging infrastructure runs alongside existing logic
- Can defer RL indefinitely if rule-based routing suffices

## Usage Examples
- "Build n8n workflow to triage SkySpark alerts"
- "Create FastAPI server for energy calculations"
- "Set up multi-agent routing for HVAC diagnostics"
- "Design workflow for automated building system reports"
- "Integrate n8n with SkySpark Haystack API"
- "Design stateless agent with standardized I/O for future RL"
- "Set up diagnostic episode logging infrastructure"
- "Implement rule-based agent router for Phase 2"
