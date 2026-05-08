---
name: scout-travel-agent
description: "Build agentic AI applications with multi-step task orchestration, tool calling, and state management. Use when creating AI agents that autonomously perform complex workflows like the Scout Travel Concierge - an agent that searches flights, checks hotel availability, and manages calendar invites through real API integrations. Triggers: agentic workflows, tool use orchestration, LangChain/LangGraph agents, travel planning agents, multi-step AI automation, autonomous task execution."
---

# Scout: Agentic Travel Concierge

Build an AI agent that autonomously plans trips by calling real APIs for flights, hotels, and calendar management.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Scout Agent                             │
├─────────────────────────────────────────────────────────────────┤
│  LangGraph State Machine                                        │
│  ┌─────────┐    ┌──────────┐    ┌─────────┐    ┌────────────┐  │
│  │ Intake  │───▶│ Research │───▶│ Compare │───▶│  Finalize  │  │
│  └─────────┘    └──────────┘    └─────────┘    └────────────┘  │
├─────────────────────────────────────────────────────────────────┤
│  Tool Layer                                                     │
│  ┌──────────┐ ┌───────────┐ ┌──────────┐ ┌─────────────────┐   │
│  │ Flights  │ │  Hotels   │ │ Calendar │ │ Vector Memory   │   │
│  │ (SerpApi)│ │(Skyscanner)│ │ (Google) │ │ (Pinecone)      │   │
│  └──────────┘ └───────────┘ └──────────┘ └─────────────────────┘
└─────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
scout/
├── agent/
│   ├── graph.py          # LangGraph state machine
│   ├── nodes.py          # Node functions (intake, research, compare, finalize)
│   └── state.py          # TypedDict state schema
├── tools/
│   ├── flights.py        # Flight search tool
│   ├── hotels.py         # Hotel availability tool
│   ├── calendar.py       # Calendar integration tool
│   └── memory.py         # Vector store for preferences
├── config/
│   └── settings.py       # API keys, model config
├── main.py               # Entry point
└── requirements.txt
```

## Core Implementation

### 1. State Schema

```python
# agent/state.py
from typing import TypedDict, Annotated, Sequence
from langchain_core.messages import BaseMessage
from langgraph.graph.message import add_messages

class TravelState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], add_messages]
    destination: str
    dates: dict  # {"start": "2025-03-15", "end": "2025-03-22"}
    budget: dict  # {"flights": 500, "hotels": 1000, "total": 2000}
    travelers: int
    preferences: dict  # {"airline": "any", "hotel_stars": 4, "direct_only": False}
    flight_options: list
    hotel_options: list
    selected_flights: dict
    selected_hotel: dict
    calendar_event_id: str
    stage: str  # "intake" | "research" | "compare" | "finalize" | "complete"
```

### 2. Tool Definitions

```python
# tools/flights.py
from langchain_core.tools import tool
from typing import Optional
import httpx

@tool
def search_flights(
    origin: str,
    destination: str,
    departure_date: str,
    return_date: Optional[str] = None,
    adults: int = 1,
    direct_only: bool = False,
    max_price: Optional[int] = None
) -> dict:
    """Search for flights using SerpApi Google Flights.
    
    Args:
        origin: IATA airport code (e.g., "SFO")
        destination: IATA airport code (e.g., "NRT")
        departure_date: Format YYYY-MM-DD
        return_date: Format YYYY-MM-DD, omit for one-way
        adults: Number of passengers
        direct_only: If True, only return non-stop flights
        max_price: Maximum price in USD
    
    Returns:
        dict with "flights" list containing price, airline, duration, stops
    """
    params = {
        "engine": "google_flights",
        "departure_id": origin,
        "arrival_id": destination,
        "outbound_date": departure_date,
        "return_date": return_date,
        "adults": adults,
        "type": "1" if direct_only else "2",
        "api_key": settings.SERPAPI_KEY
    }
    
    response = httpx.get("https://serpapi.com/search", params=params)
    data = response.json()
    
    flights = []
    for flight in data.get("best_flights", []) + data.get("other_flights", []):
        price = flight.get("price")
        if max_price and price > max_price:
            continue
        flights.append({
            "price": price,
            "airline": flight["flights"][0]["airline"],
            "duration": flight["total_duration"],
            "stops": len(flight["flights"]) - 1,
            "departure": flight["flights"][0]["departure_airport"]["time"],
            "arrival": flight["flights"][-1]["arrival_airport"]["time"],
            "booking_token": flight.get("booking_token")
        })
    
    return {"flights": sorted(flights, key=lambda x: x["price"])[:10]}
```

```python
# tools/hotels.py
@tool
def search_hotels(
    destination: str,
    checkin: str,
    checkout: str,
    guests: int = 2,
    min_stars: int = 3,
    max_price_per_night: Optional[int] = None
) -> dict:
    """Search hotel availability using Skyscanner API.
    
    Args:
        destination: City name or airport code
        checkin: Format YYYY-MM-DD
        checkout: Format YYYY-MM-DD
        guests: Number of guests
        min_stars: Minimum star rating (1-5)
        max_price_per_night: Maximum nightly rate in USD
    
    Returns:
        dict with "hotels" list containing name, price, rating, amenities
    """
    # Implementation with Skyscanner or alternative hotel API
    pass
```

```python
# tools/calendar.py
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

@tool
def create_trip_event(
    title: str,
    start_date: str,
    end_date: str,
    description: str,
    location: str
) -> dict:
    """Create a calendar event for the trip.
    
    Args:
        title: Event title (e.g., "Tokyo Trip")
        start_date: Format YYYY-MM-DD
        end_date: Format YYYY-MM-DD
        description: Trip details including flight/hotel info
        location: Destination city
    
    Returns:
        dict with "event_id" and "link" to calendar event
    """
    creds = Credentials.from_authorized_user_file("token.json")
    service = build("calendar", "v3", credentials=creds)
    
    event = {
        "summary": title,
        "location": location,
        "description": description,
        "start": {"date": start_date},
        "end": {"date": end_date},
    }
    
    result = service.events().insert(calendarId="primary", body=event).execute()
    return {"event_id": result["id"], "link": result["htmlLink"]}
```

```python
# tools/memory.py
from langchain_pinecone import PineconeVectorStore
from langchain_openai import OpenAIEmbeddings

@tool
def store_preference(user_id: str, preference_type: str, value: str) -> dict:
    """Store user travel preference in vector memory.
    
    Args:
        user_id: Unique user identifier
        preference_type: Category (e.g., "airline", "hotel_chain", "seat_class")
        value: Preference value
    
    Returns:
        Confirmation of stored preference
    """
    vectorstore = PineconeVectorStore(
        index_name="scout-preferences",
        embedding=OpenAIEmbeddings()
    )
    vectorstore.add_texts(
        texts=[f"{preference_type}: {value}"],
        metadatas=[{"user_id": user_id, "type": preference_type}]
    )
    return {"stored": True, "preference": f"{preference_type}={value}"}

@tool
def recall_preferences(user_id: str, query: str) -> dict:
    """Retrieve relevant user preferences.
    
    Args:
        user_id: Unique user identifier
        query: Context for preference lookup (e.g., "booking flights to Japan")
    
    Returns:
        List of relevant stored preferences
    """
    vectorstore = PineconeVectorStore(
        index_name="scout-preferences",
        embedding=OpenAIEmbeddings()
    )
    results = vectorstore.similarity_search(
        query,
        k=5,
        filter={"user_id": user_id}
    )
    return {"preferences": [doc.page_content for doc in results]}
```

### 3. LangGraph Workflow

```python
# agent/graph.py
from langgraph.graph import StateGraph, END
from langgraph.prebuilt import ToolNode
from langchain_anthropic import ChatAnthropic
from .state import TravelState
from .nodes import intake_node, research_node, compare_node, finalize_node

# Initialize model with tools
model = ChatAnthropic(model="claude-sonnet-4-20250514", temperature=0)
tools = [search_flights, search_hotels, create_trip_event, store_preference, recall_preferences]
model_with_tools = model.bind_tools(tools)

# Build graph
workflow = StateGraph(TravelState)

# Add nodes
workflow.add_node("intake", intake_node)
workflow.add_node("research", research_node)
workflow.add_node("tools", ToolNode(tools))
workflow.add_node("compare", compare_node)
workflow.add_node("finalize", finalize_node)

# Define edges
workflow.set_entry_point("intake")
workflow.add_edge("intake", "research")
workflow.add_conditional_edges(
    "research",
    should_use_tools,
    {"tools": "tools", "compare": "compare"}
)
workflow.add_edge("tools", "research")  # Loop back after tool execution
workflow.add_edge("compare", "finalize")
workflow.add_edge("finalize", END)

# Compile
agent = workflow.compile()
```

```python
# agent/nodes.py
from langchain_core.messages import HumanMessage, AIMessage

def intake_node(state: TravelState) -> dict:
    """Extract travel requirements from user input."""
    messages = state["messages"]
    
    response = model_with_tools.invoke([
        {"role": "system", "content": """Extract travel details from the user's request:
        - Destination (city/country)
        - Dates (start and end)
        - Budget (total or per-category)
        - Number of travelers
        - Preferences (airline, hotel class, direct flights, etc.)
        
        If any required info is missing, ask clarifying questions."""},
        *messages
    ])
    
    return {
        "messages": [response],
        "stage": "research"
    }

def research_node(state: TravelState) -> dict:
    """Search for flights and hotels using tools."""
    response = model_with_tools.invoke([
        {"role": "system", "content": """You are researching travel options.
        Use search_flights and search_hotels tools to find options within budget.
        First recall any stored user preferences with recall_preferences.
        Search for 3-5 flight options and 3-5 hotel options."""},
        *state["messages"]
    ])
    
    return {"messages": [response]}

def should_use_tools(state: TravelState) -> str:
    """Route to tools if model requested tool calls."""
    last_message = state["messages"][-1]
    if hasattr(last_message, "tool_calls") and last_message.tool_calls:
        return "tools"
    return "compare"

def compare_node(state: TravelState) -> dict:
    """Present options and help user choose."""
    response = model_with_tools.invoke([
        {"role": "system", "content": """Present the flight and hotel options clearly:
        
        Format each option with:
        - Price and value comparison
        - Key features (stops, duration, amenities)
        - Your recommendation based on their preferences
        
        Ask which options they'd like to book."""},
        *state["messages"]
    ])
    
    return {"messages": [response], "stage": "finalize"}

def finalize_node(state: TravelState) -> dict:
    """Create calendar event and confirm booking details."""
    response = model_with_tools.invoke([
        {"role": "system", "content": """Finalize the trip:
        1. Summarize selected flights and hotel
        2. Use create_trip_event to add to their calendar
        3. Store any new preferences with store_preference
        4. Provide booking links and next steps"""},
        *state["messages"]
    ])
    
    return {"messages": [response], "stage": "complete"}
```

### 4. Entry Point

```python
# main.py
from agent.graph import agent
from agent.state import TravelState

def run_scout(user_input: str, user_id: str = "default"):
    """Run the Scout travel agent."""
    initial_state: TravelState = {
        "messages": [{"role": "user", "content": user_input}],
        "destination": "",
        "dates": {},
        "budget": {},
        "travelers": 1,
        "preferences": {},
        "flight_options": [],
        "hotel_options": [],
        "selected_flights": {},
        "selected_hotel": {},
        "calendar_event_id": "",
        "stage": "intake"
    }
    
    result = agent.invoke(initial_state)
    return result["messages"][-1].content

if __name__ == "__main__":
    response = run_scout(
        "Plan a week-long trip to Tokyo in March for 2 people. "
        "Budget is $3000 total. We prefer direct flights and 4-star hotels."
    )
    print(response)
```

## Requirements

```
# requirements.txt
langchain>=0.3.0
langgraph>=0.2.0
langchain-anthropic>=0.2.0
langchain-openai>=0.2.0
langchain-pinecone>=0.2.0
pinecone-client>=3.0.0
google-api-python-client>=2.100.0
google-auth-oauthlib>=1.1.0
httpx>=0.27.0
python-dotenv>=1.0.0
```

## API Setup

### Required API Keys

| Service | Purpose | Get Key |
|---------|---------|---------|
| Anthropic | LLM for agent reasoning | console.anthropic.com |
| SerpApi | Flight search (Google Flights) | serpapi.com |
| Skyscanner | Hotel availability | partners.skyscanner.net |
| Pinecone | Vector memory for preferences | pinecone.io |
| Google Cloud | Calendar integration | console.cloud.google.com |

### Environment Configuration

```bash
# .env
ANTHROPIC_API_KEY=sk-ant-...
SERPAPI_API_KEY=...
SKYSCANNER_API_KEY=...
PINECONE_API_KEY=...
PINECONE_ENVIRONMENT=us-east-1
GOOGLE_CREDENTIALS_PATH=./credentials.json
```

## Key Concepts for Resume

### Tool Use Orchestration

The agent demonstrates sophisticated tool calling:

- **Structured outputs**: Tools use typed parameters with validation
- **Conditional routing**: Graph decides when to call tools vs proceed
- **Tool chaining**: Research node may call multiple tools in sequence

### State Management

LangGraph provides:

- **Typed state**: TypedDict ensures consistent state shape
- **Reducers**: `add_messages` accumulates conversation history
- **Checkpointing**: Can persist state for long-running workflows

### Vector Memory

Pinecone integration enables:

- **Preference learning**: Store and recall user preferences across sessions
- **Semantic search**: Find relevant preferences based on context
- **Personalization**: Agent improves recommendations over time

## Testing

```python
# tests/test_tools.py
import pytest
from tools.flights import search_flights

def test_flight_search():
    result = search_flights(
        origin="SFO",
        destination="NRT",
        departure_date="2025-03-15",
        return_date="2025-03-22",
        adults=2
    )
    assert "flights" in result
    assert len(result["flights"]) > 0
    assert all("price" in f for f in result["flights"])
```

```python
# tests/test_agent.py
from agent.graph import agent

def test_full_workflow():
    result = agent.invoke({
        "messages": [{"role": "user", "content": "Find flights from SFO to Tokyo"}],
        "stage": "intake"
    })
    assert result["stage"] == "complete"
    assert len(result["flight_options"]) > 0
```

## Extending Scout

### Add New Tools

1. Define tool with `@tool` decorator
2. Add clear docstring with Args/Returns
3. Include in `tools` list when binding to model

### Add New Workflow Stages

1. Define node function in `nodes.py`
2. Add node to graph with `workflow.add_node()`
3. Define edges for routing

### Alternative APIs

| Category | Alternatives |
|----------|-------------|
| Flights | Amadeus, Travelport, Duffel |
| Hotels | Booking.com, Hotels.com API, Amadeus |
| LLM | OpenAI, Google Gemini, local models |
| Vector DB | Weaviate, Chroma, Qdrant |