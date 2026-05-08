---
name: deepagents-integration
description: deepagents framework integration patterns for agent creation, planning, filesystem operations, and subagent orchestration. Current version 0.2.5 with LangGraph 1.0.2+
triggers:
  keywords: ["deepagents", "DeepAgent", "langgraph", "planning", "write_todos", "subagent", "agent creation", "filesystem middleware", "mcp servers"]
  file_patterns: ["**/deepagents_integration/**/*.py", "**/services/*_service.py", "**/api/v1/agents.py"]
  context: ["creating AI agents", "agent configuration", "deepagents setup", "planning system", "agent orchestration"]
---

# deepagents Integration Skill

Expert patterns for integrating the deepagents framework (v0.2.5+) with LangGraph 1.0.2+ and LangChain 1.0.3+ for the DeepAgents Control Platform.

## 🎯 When to Use This Skill

**Auto-activates when:**
- Keywords mentioned: `deepagents`, `DeepAgent`, `langgraph`, `planning`, `subagent`, `write_todos`
- Working with files: `backend/deepagents_integration/`, `services/agent_service.py`, `api/v1/agents.py`
- Tasks: agent creation, planning configuration, filesystem operations, subagent orchestration

**NOT for:**
- FastAPI routing/dependencies → use `fastapi-patterns` skill
- Frontend components → use `react-enterprise` skill
- Database models → use `fastapi-patterns` skill (includes SQLAlchemy)

## ⚡ Quick Reference

### Top 10 Essential Patterns

```python
# 1. Simple Agent Creation (2025 API)
from deepagents import DeepAgent

agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    planning=True,
    filesystem=True,
    system_prompt="You are an expert assistant..."
)

# 2. Async Agent Creation (for MCP servers)
from deepagents import async_create_deep_agent

agent = await async_create_deep_agent(
    model="claude-sonnet-4-5-20250929",
    mcp_servers=["playwright", "memory"],
    planning=True
)

# 3. Execute Agent with Config
result = await agent.ainvoke(
    "Your task here",
    config={"configurable": {"thread_id": "session_123"}}
)

# 4. LangGraph State (TypedDict + Annotated)
from typing import Annotated, TypedDict
from langgraph.graph.message import add_messages
from langchain_core.messages import BaseMessage

class AgentState(TypedDict):
    messages: Annotated[list[BaseMessage], add_messages]
    todos: Annotated[list[dict], lambda x, y: y]  # Replace strategy
    context: dict

# 5. Custom Tool Definition
from langchain_core.tools import tool
from pydantic import BaseModel, Field

class AnalysisInput(BaseModel):
    query: str = Field(description="Analysis query")
    
@tool(args_schema=AnalysisInput)
def analyze_data(query: str) -> str:
    """Analyze data based on query."""
    return f"Analysis result for: {query}"

# 6. Agent with Custom Tools
agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    tools=[analyze_data],
    planning=True
)

# 7. Subagent Creation
main_agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    subagents=[
        Subagent(
            name="researcher",
            model="claude-haiku-4-20250508",
            system_prompt="Research specialist",
            tools=[search_tool]
        )
    ]
)

# 8. File Operations (Security Built-in)
# ✅ Allowed - relative paths only
agent.file_read("data/report.txt")
agent.file_write("output/results.json", content)

# ❌ Blocked - path traversal prevention
agent.file_read("../../../etc/passwd")  # Raises error

# 9. Planning Prompt Structure
system_prompt = """
You are a planning expert. Use write_todos for complex tasks.

## Planning Guidelines:
- Use write_todos for tasks requiring > 3 steps
- Create dependencies between tasks
- Update status: pending → in_progress → completed
"""

# 10. Error Handling Pattern
try:
    result = await agent.ainvoke(task, config=config)
except Exception as e:
    logger.error(f"Agent execution failed: {e}")
    # Save partial results if available
    await save_execution_state(agent.state)
```

## 📁 Project Structure

```
backend/
├── deepagents_integration/        # deepagents framework integration
│   ├── __init__.py
│   ├── factory.py                 # Agent creation from DB configs
│   ├── executor.py                # Agent execution management
│   └── tools/                     # Custom tool definitions
│       ├── __init__.py
│       ├── file_tools.py          # File operation tools
│       └── data_tools.py          # Data analysis tools
├── api/v1/
│   ├── agents.py                  # Agent CRUD endpoints
│   └── executions.py              # Agent execution endpoints
├── services/
│   ├── agent_service.py           # Agent business logic
│   └── execution_service.py       # Execution tracking
├── models/
│   ├── agent.py                   # Agent SQLAlchemy model
│   └── execution.py               # Execution SQLAlchemy model
└── schemas/
    ├── agent.py                   # Agent Pydantic schemas
    └── execution.py               # Execution Pydantic schemas
```

## 🔧 Core Patterns

### 1. Agent Creation Pattern (2025 API)

**Use case**: Creating agents from platform configuration

```python
from deepagents import DeepAgent, Subagent
from typing import Annotated, TypedDict
from langgraph.graph.message import add_messages
from langchain_core.messages import BaseMessage

# Type-safe state definition
class AgentState(TypedDict):
    """Agent state with type safety and reducers."""
    messages: Annotated[list[BaseMessage], add_messages]
    todos: Annotated[list[dict], lambda x, y: y]  # Replace strategy
    context: dict
    error: str | None

# ✅ CORRECT: Agent with all features
agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    planning=True,              # Enables write_todos tool
    filesystem=True,            # Enables file_read/write/list
    system_prompt="Expert assistant with planning capabilities",
    state_schema=AgentState,    # Type-safe state
    temperature=0.7,
    max_tokens=4096
)

# ❌ WRONG: Missing state_schema for complex state
agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    # Missing state_schema - will use default MessagesState only
)

# 🔒 Security: Built-in path traversal prevention
# File operations automatically restricted to workspace
```

**Troubleshooting**:
- **Error: "Model not found"** → Check `ANTHROPIC_API_KEY` or `OPENAI_API_KEY` environment variable
- **Planning not working** → Ensure `planning=True` and system prompt mentions `write_todos`
- **State not persisting** → Add `config={"configurable": {"thread_id": "unique_id"}}`

---

### 2. Planning System (write_todos)

**Use case**: Task decomposition for complex multi-step operations

```python
# System prompt for planning-enabled agents
planning_prompt = """
You are an expert assistant with planning capabilities.

## When to Plan:
- Tasks requiring > 3 steps → use write_todos
- Complex workflows → break down into subtasks
- Long-running operations → track progress with todos

## Planning Structure:
{
  "todos": [
    {
      "description": "Specific, actionable task",
      "status": "pending",  // or "in_progress", "completed"
      "dependencies": [],   // Array of task indices
      "priority": "high"    // Optional: high, medium, low
    }
  ]
}

## Planning Best Practices:
1. Create clear, specific task descriptions
2. Use dependencies for sequential tasks
3. Update status as you progress
4. Revise plan when discovering new requirements
"""

agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    planning=True,  # Adds write_todos tool automatically
    system_prompt=planning_prompt
)

# Agent will automatically use write_todos like this:
# {
#   "tool": "write_todos",
#   "input": {
#     "todos": [
#       {"description": "Analyze requirements", "status": "pending", "dependencies": []},
#       {"description": "Design solution", "status": "pending", "dependencies": [0]},
#       {"description": "Implement code", "status": "pending", "dependencies": [1]}
#     ]
#   }
# }

# ❌ WRONG: Vague todo descriptions
# {"description": "Do the thing"}  # Too vague

# ✅ CORRECT: Specific todo descriptions
# {"description": "Extract user data from PostgreSQL users table"}
```

**Troubleshooting**:
- **Todos not created** → Check that `planning=True` is set
- **Agent ignores todos** → Add explicit planning instructions to system prompt
- **Circular dependencies** → Validate dependency graph before execution

---

### 3. Filesystem Middleware (Security-Enhanced)

**Use case**: File operations with built-in security

```python
from deepagents import DeepAgent

# ✅ CORRECT: Enable filesystem with security
agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",
    filesystem=True,  # Enables: file_read, file_write, file_list
    system_prompt="Assistant with file access capabilities"
)

# Built-in tools when filesystem=True:
# - file_read(path: str) -> str
# - file_write(path: str, content: str) -> str
# - file_list(path: str) -> list[str]
# - file_delete(path: str) -> str  # Optional, disabled by default

# 🔒 Security: Automatic path traversal prevention
# ✅ Allowed
agent.file_read("data/report.txt")
agent.file_read("./output/results.json")

# ❌ Blocked (raises SecurityError)
agent.file_read("../../../etc/passwd")
agent.file_read("/etc/hosts")

# Use case: Large file chunked reading
chunked_prompt = """
When reading large files:
1. Use file_list to check file size
2. Read in chunks if > 50KB
3. Process incrementally to avoid context overflow
"""

# Use case: Context offloading
offloading_prompt = """
For data exceeding token limits:
1. Analyze data incrementally
2. Write intermediate results to files
3. Provide summary in final response

Example:
- file_write("analysis_part1.json", results_1)
- file_write("analysis_part2.json", results_2)
- file_write("summary.txt", final_summary)
"""
```

**Troubleshooting**:
- **Permission denied** → Check file/directory permissions in filesystem
- **Path traversal error** → Use relative paths only (no `../` or absolute paths)
- **File too large** → Implement chunked reading pattern (see above)

**Security Best Practices**:
- ✅ Always use relative paths
- ✅ Validate file extensions if needed
- ✅ Set size limits for file operations
- ❌ Never expose sensitive system paths

---

### 4. Subagent Orchestration

**Use case**: Hierarchical agent systems with specialized subagents

```python
from deepagents import DeepAgent, Subagent

# ✅ CORRECT: Main coordinator with specialized subagents
main_agent = DeepAgent.create(
    model="claude-sonnet-4-5-20250929",  # Powerful model for coordination
    planning=True,
    system_prompt="You coordinate specialized subagents for complex tasks",
    subagents=[
        Subagent(
            name="researcher",
            model="claude-haiku-4-20250508",  # Fast, cost-effective
            system_prompt="Research specialist - find and summarize information",
            tools=[search_tool, web_scraper_tool],
            context_isolation=False  # Shares context with main agent
        ),
        Subagent(
            name="coder",
            model="claude-sonnet-4-5-20250929",  # Powerful for coding
            system_prompt="Code generation specialist",
            tools=[code_analyzer_tool],
            context_isolation=True  # Isolated context for security
        ),
        Subagent(
            name="validator",
            model="claude-haiku-4-20250508",
            system_prompt="Validate outputs for quality and correctness",
            context_isolation=False
        )
    ]
)

# Subagent delegation happens automatically based on task
result = await main_agent.ainvoke(
    "Research Python best practices and generate example code"
)
# Main agent will:
# 1. Delegate research to "researcher" subagent
# 2. Delegate coding to "coder" subagent
# 3. Delegate validation to "validator" subagent

# ❌ WRONG: Using expensive model for simple tasks
Subagent(
    name="simple_formatter",
    model="claude-opus-4-20250514",  # Overkill for formatting
    system_prompt="Format text"
)

# ✅ CORRECT: Match model to task complexity
Subagent(
    name="formatter",
    model="claude-haiku-4-20250508",  # Cost-effective for simple tasks
    system_prompt="Format text output"
)

# 🔒 Security: Context isolation for sensitive operations
Subagent(
    name="data_processor",
    model="claude-sonnet-4-5-20250929",
    tools=[database_tool],
    context_isolation=True,  # Prevents context leakage
    system_prompt="Process sensitive user data"
)
```

**Troubleshooting**:
- **Subagent not invoked** → Ensure main agent's prompt mentions delegation
- **Context not shared** → Set `context_isolation=False` if context sharing is needed
- **High costs** → Use Haiku for simple subagents, Sonnet/Opus for complex ones

---

### 5. Platform Integration (DeepAgents Control Platform)

**Use case**: Creating agents from database configurations

```python
# services/agent_service.py
from deepagents import DeepAgent, Subagent
from models.agent import Agent
from models.tool import Tool
from sqlalchemy.ext.asyncio import AsyncSession

class DeepAgentsFactory:
    """Factory for creating deepagents from platform configurations."""
    
    @staticmethod
    async def create_from_config(
        db: AsyncSession,
        agent_config: Agent
    ) -> DeepAgent:
        """
        Create DeepAgent from database configuration.
        
        Args:
            db: Database session
            agent_config: Agent model from database
            
        Returns:
            Configured DeepAgent instance
        """
        # Load custom tools
        tools = await db.scalars(
            select(Tool).where(Tool.id.in_(agent_config.tool_ids))
        )
        custom_tools = [tool.to_langchain_tool() for tool in tools]
        
        # Load subagents
        subagents = []
        for subagent_config in agent_config.subagents:
            subagent = Subagent(
                name=subagent_config.name,
                model=subagent_config.model_name,
                system_prompt=subagent_config.system_prompt,
                context_isolation=subagent_config.context_isolation
            )
            subagents.append(subagent)
        
        # Create agent
        agent = DeepAgent.create(
            model=agent_config.model_name,
            planning=agent_config.planning_enabled,
            filesystem=agent_config.filesystem_enabled,
            system_prompt=agent_config.system_prompt,
            tools=custom_tools,
            subagents=subagents,
            temperature=agent_config.temperature,
            max_tokens=agent_config.max_tokens
        )
        
        return agent


# services/execution_service.py
from models.execution import Execution
from schemas.execution import ExecutionCreate

class AgentExecutionService:
    """Manage agent execution with tracking and tracing."""
    
    async def execute_agent(
        self,
        db: AsyncSession,
        agent_id: int,
        task: str,
        user_id: int
    ) -> dict:
        """
        Execute agent and track execution.
        
        Args:
            db: Database session
            agent_id: Agent ID from database
            task: Task description
            user_id: User ID initiating execution
            
        Returns:
            Execution result with metadata
        """
        # Load agent config
        agent_config = await db.get(Agent, agent_id)
        
        # Create execution record
        execution = Execution(
            agent_id=agent_id,
            user_id=user_id,
            input_text=task,
            status="pending"
        )
        db.add(execution)
        await db.commit()
        
        try:
            # Create agent instance
            agent = await DeepAgentsFactory.create_from_config(db, agent_config)
            
            # Execute with thread ID for state persistence
            config = {
                "configurable": {
                    "thread_id": f"execution_{execution.id}"
                }
            }
            
            execution.status = "running"
            await db.commit()
            
            result = await agent.ainvoke(task, config=config)
            
            # Update execution record
            execution.status = "completed"
            execution.output_text = result.get("output", "")
            execution.token_usage = result.get("token_usage", {})
            execution.execution_time = result.get("execution_time", 0)
            
        except Exception as e:
            execution.status = "failed"
            execution.error_message = str(e)
            raise
        
        finally:
            await db.commit()
        
        return {
            "execution_id": execution.id,
            "status": execution.status,
            "result": execution.output_text
        }
```

**Troubleshooting**:
- **Agent not persisting state** → Ensure unique `thread_id` per execution
- **Tools not loading** → Verify `tool.to_langchain_tool()` method exists
- **High memory usage** → Implement agent instance pooling

---

## 🔗 Custom Tool Development

**Use case**: Creating domain-specific tools for agents

```python
from langchain_core.tools import tool
from pydantic import BaseModel, Field
import httpx

# ✅ CORRECT: Tool with Pydantic schema validation
class DatabaseQueryInput(BaseModel):
    """Input schema for database queries."""
    query: str = Field(description="SQL query to execute")
    limit: int = Field(default=100, ge=1, le=1000, description="Result limit")

@tool(args_schema=DatabaseQueryInput)
async def query_database(query: str, limit: int = 100) -> str:
    """
    Execute database query with safety checks.
    
    Args:
        query: SQL query (SELECT only)
        limit: Maximum rows to return
        
    Returns:
        JSON-formatted query results
    
    Security:
        - Only SELECT queries allowed
        - Query timeout: 30 seconds
        - Result limit enforced
    """
    # 🔒 Security: Validate query type
    if not query.strip().upper().startswith("SELECT"):
        raise ValueError("Only SELECT queries allowed")
    
    # Execute with timeout and limit
    # ... implementation ...
    
    return json.dumps(results)

# ❌ WRONG: No input validation
@tool
def unsafe_query(query):  # No type hints, no validation
    return execute_sql(query)  # SQL injection risk!

# ✅ CORRECT: Async tool with error handling
@tool(args_schema=AnalysisInput)
async def fetch_external_data(url: str) -> str:
    """Fetch data from external API with timeout."""
    async with httpx.AsyncClient(timeout=10.0) as client:
        try:
            response = await client.get(url)
            response.raise_for_status()
            return response.text
        except httpx.TimeoutException:
            return "Error: Request timed out"
        except httpx.HTTPError as e:
            return f"Error: {str(e)}"
```

**Security Best Practices**:
- ✅ Always use Pydantic schemas for input validation
- ✅ Set timeouts for external operations
- ✅ Validate and sanitize all inputs
- ✅ Use async for I/O operations
- ❌ Never execute arbitrary code from tool inputs
- ❌ Don't expose sensitive credentials in tool outputs

---

## 📊 MCP Server Integration

**Use case**: Using Model Context Protocol servers

```python
from deepagents import async_create_deep_agent

# Async creation required for MCP servers
agent = await async_create_deep_agent(
    model="claude-sonnet-4-5-20250929",
    mcp_servers=["playwright", "memory", "filesystem"],  # MCP server names
    planning=True,
    system_prompt="Assistant with browser automation and memory capabilities"
)

# MCP servers provide additional tools:
# - playwright: Browser automation (navigate, click, screenshot, etc.)
# - memory: Knowledge graph operations
# - filesystem: Enhanced file operations

# ❌ WRONG: Using sync creation with MCP servers
agent = DeepAgent.create(  # Won't work with MCP!
    mcp_servers=["playwright"]
)

# ✅ CORRECT: Async creation
agent = await async_create_deep_agent(
    mcp_servers=["playwright"]
)
```

**Troubleshooting**:
- **MCP server not found** → Check MCP server configuration in environment
- **Async context error** → Use `await async_create_deep_agent`, not `DeepAgent.create`
- **Tools not available** → Verify MCP server is running and accessible

---

## 🎯 Best Practices Summary

### DO ✅
- Use `async_create_deep_agent` for MCP server integration
- Set `planning=True` for multi-step tasks
- Use `TypedDict` with `Annotated` for complex state
- Match model to task complexity (Haiku for simple, Sonnet/Opus for complex)
- Implement error handling and execution tracking
- Use `thread_id` for state persistence across conversations
- Validate all tool inputs with Pydantic schemas
- Set timeouts for external operations

### DON'T ❌
- Don't use absolute paths in filesystem operations
- Don't skip input validation in custom tools
- Don't use expensive models for simple subagents
- Don't ignore error handling in agent execution
- Don't expose sensitive data in tool outputs
- Don't create agents without proper configuration tracking

---

## 📚 See Also

- **reference.md** - Complete deepagents API documentation
- **examples.md** - Full working examples and use cases
- **fastapi-patterns** - Backend integration patterns
- **react-enterprise** - Frontend agent management UI
