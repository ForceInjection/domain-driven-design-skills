---
name: workflow-ui-generator
description: Generate React Flow workflow UIs with nodes, edges, execution orchestration, and chat interfaces. Use when creating workflow visualizations, multi-step processes, DAG systems, or orchestrated task flows.
---

# Workflow UI Generator

## Overview

This skill helps you create complete React Flow-based workflow applications with:
- **Visual workflow graphs** with custom nodes and edges
- **Layer-based execution** using topological sorting
- **Real-time status animations** for node execution states
- **Chat interfaces** for workflow generation via LLM
- **API integration** for workflow planning and execution

## When to Use This Skill

Activate this skill when you need to:
- Create workflow visualization UIs with React Flow
- Build multi-step process orchestrators
- Implement DAG (Directed Acyclic Graph) execution systems
- Generate workflows from natural language prompts
- Visualize task dependencies and execution flows
- Create script generation or video production workflows

## Core Architecture Patterns

### 1. Workflow Data Model

```typescript
// Node types with execution metadata
export interface WorkflowNode {
  id: string;
  label: string;
  kind: string;  // e.g., "collect", "ideate", "draft", "review"
  summary?: string;
  prompts?: string[];
  parallelGroup?: string;
}

// Edge connections
export interface WorkflowEdge {
  id: string;
  source: string;
  target: string;
  label?: string;
}

// Execution states
export type WorkflowNodeStatus = "pending" | "running" | "completed" | "failed";

// Results with execution data
export interface WorkflowResult {
  nodes: Array<WorkflowNode & {
    status: WorkflowNodeStatus;
    layer: number;
    output?: string
  }>;
  edges: WorkflowEdge[];
  frames: WorkflowFrame[];
}
```

### 2. Layer-Based Execution (Topological Sort)

The workflow executor uses topological sorting to determine execution order:

```typescript
function buildLayers(nodes: WorkflowNode[], edges: WorkflowEdge[]): string[][] {
  // Build adjacency list and track indegrees
  const indegree = new Map<string, number>();
  const adjacency = new Map<string, Set<string>>();

  // Initialize all nodes
  for (const node of nodes) {
    indegree.set(node.id, 0);
    adjacency.set(node.id, new Set());
  }

  // Build graph from edges
  for (const edge of edges) {
    adjacency.get(edge.source)!.add(edge.target);
    indegree.set(edge.target, (indegree.get(edge.target) ?? 0) + 1);
  }

  // Kahn's algorithm for topological sort
  const layers: string[][] = [];
  let current = Array.from(nodes.map(n => n.id))
    .filter(id => (indegree.get(id) ?? 0) === 0);

  while (current.length > 0) {
    layers.push(current);
    const next = new Set<string>();

    for (const nodeId of current) {
      const neighbors = adjacency.get(nodeId);
      if (!neighbors) continue;

      for (const neighbor of neighbors) {
        const nextIndegree = (indegree.get(neighbor) ?? 0) - 1;
        indegree.set(neighbor, nextIndegree);
        if (nextIndegree === 0) {
          next.add(neighbor);
        }
      }
    }

    current = Array.from(next);
  }

  return layers;
}
```

### 3. React Flow Visualization

Convert workflow layers into positioned React Flow nodes:

```typescript
function buildGraph(
  workflow: WorkflowResult | null,
  animatedStatuses: Record<string, WorkflowNodeStatus>
): { nodes: FlowNode[]; edges: FlowEdge[] } {
  if (!workflow) return { nodes: [], edges: [] };

  // Group nodes by layer
  const layers = new Map<number, WorkflowNode[]>();
  for (const node of workflow.nodes) {
    const layerGroup = layers.get(node.layer) ?? [];
    layerGroup.push(node);
    layers.set(node.layer, layerGroup);
  }

  const sortedLayers = Array.from(layers.entries()).sort((a, b) => a[0] - b[0]);
  const nodes: FlowNode[] = [];

  const columnOffset = 320;  // Horizontal spacing
  const rowOffset = 180;     // Vertical spacing

  // Position nodes in a grid based on layers
  for (const [layerIndex, layerNodes] of sortedLayers) {
    const middle = (layerNodes.length - 1) / 2;

    layerNodes.forEach((node, index) => {
      nodes.push({
        id: node.id,
        position: {
          x: layerIndex * columnOffset,
          y: (index - middle) * rowOffset,  // Center vertically
        },
        data: {
          label: <NodeCard node={node} status={status} />,
        },
      });
    });
  }

  // Create edges with animations
  const edges: FlowEdge[] = workflow.edges.map(edge => ({
    id: edge.id,
    source: edge.source,
    target: edge.target,
    type: "smoothstep",
    animated: animatedStatuses[edge.source] === "running",
    style: { strokeWidth: 1.6 },
  }));

  return { nodes, edges };
}
```

### 4. Custom Node Components

Create status-aware node cards:

```jsx
function NodeCard({ node, status, isActive }) {
  const theme = {
    pending: {
      container: "border-dashed border-border/80 bg-muted/30",
      badge: "bg-muted text-muted-foreground",
    },
    running: {
      container: "border-amber-500/70 bg-amber-100/60 animate-pulse",
      badge: "bg-amber-500 text-amber-900",
    },
    completed: {
      container: "border-emerald-500/70 bg-emerald-50",
      badge: "bg-emerald-500 text-emerald-950",
    },
    failed: {
      container: "border-rose-500/70 bg-rose-50",
      badge: "bg-rose-500 text-rose-50",
    },
  }[status];

  return (
    <div className={cn(
      "w-64 rounded-md border bg-background p-3",
      theme.container,
      isActive && "ring-2 ring-offset-2"
    )}>
      <div className="flex items-start justify-between">
        <div>
          <p className="text-sm font-semibold">{node.label}</p>
          {node.summary && (
            <p className="text-xs text-muted-foreground">{node.summary}</p>
          )}
        </div>
        <span className={cn("px-1.5 py-0.5 text-xs", theme.badge)}>
          {status}
        </span>
      </div>
      <div className="mt-3 text-xs text-muted-foreground">
        <span>{node.kind}</span>
        <span>Layer {node.layer + 1}</span>
      </div>
    </div>
  );
}
```

### 5. Animation System

Animate status changes frame-by-frame:

```typescript
// Record frames during execution
interface WorkflowFrame {
  nodeId: string;
  status: WorkflowNodeStatus;
  note?: string;
  timestamp: string;
}

// Replay frames with delays
useEffect(() => {
  if (!workflow) return;

  let cancelled = false;
  const baseStatus = workflow.nodes.reduce((acc, node) => {
    acc[node.id] = "pending";
    return acc;
  }, {});

  setAnimatedStatuses(baseStatus);

  const play = async () => {
    for (const frame of workflow.frames) {
      if (cancelled) return;
      await delay(220);  // Animation speed
      setAnimatedStatuses(prev => ({
        ...prev,
        [frame.nodeId]: frame.status,
      }));
    }
  };

  play();

  return () => { cancelled = true; };
}, [workflow]);
```

### 6. Chat Interface Integration

Implement a chat UI for workflow generation:

```tsx
<form onSubmit={handleSubmit}>
  <textarea
    value={input}
    onChange={(e) => setInput(e.target.value)}
    placeholder="Describe the workflow you want to create..."
  />
  <button type="submit">
    {creating ? <LoaderCircle className="animate-spin" /> : <SendHorizontal />}
    {creating ? "Generating" : "Send"}
  </button>
</form>
```

### 7. API Integration Pattern

```typescript
const createPlan = async (messages: ChatMessage[]) => {
  const payload = await fetch("/api/workflow", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ messages }),
  }).then(res => res.json());

  return {
    reply: payload.reply,
    rationale: payload.rationale,
    workflow: payload.workflow,
    workflowTitle: payload.workflowTitle,
    executionId: payload.executionId,
  };
};
```

## Implementation Steps

### Step 1: Set Up Type Definitions

Create workflow types in `lib/workflows/script-orchestrator.ts`:

```typescript
export type WorkflowNodeKind =
  | "collect"
  | "ideate"
  | "draft"
  | "review"
  | "synthesize"
  | "deliver"
  | (string & {});

export interface WorkflowNode {
  id: string;
  label: string;
  kind: WorkflowNodeKind;
  summary?: string;
  prompts?: string[];
}

export interface WorkflowEdge {
  id: string;
  source: string;
  target: string;
  label?: string;
}
```

### Step 2: Implement Layer Builder

Use topological sort to build execution layers (see pattern above).

### Step 3: Create Workflow Executor

```typescript
export async function workflowOrchestrator({ plan }: WorkflowInput) {
  "use workflow";

  const frames: WorkflowFrame[] = [];
  const statusMap = new Map<string, WorkflowNodeStatus>();
  const outputMap = new Map<string, string>();

  // Initialize all as pending
  for (const node of plan.nodes) {
    statusMap.set(node.id, "pending");
  }

  const layers = buildLayers(plan.nodes, plan.edges);

  // Execute layer by layer
  for (const layer of layers) {
    await Promise.all(
      layer.map(async (nodeId) => {
        const node = nodeLookup.get(nodeId);
        if (!node) return;

        setStatus(frames, statusMap, node.id, "running");

        try {
          const runner = stepRunners[node.kind] ?? fallbackRunner;
          const output = await runner(node);
          outputMap.set(node.id, output);
          setStatus(frames, statusMap, node.id, "completed");
        } catch (error) {
          setStatus(frames, statusMap, node.id, "failed", error.message);
          throw error;
        }
      })
    );
  }

  return { nodes: enrichedNodes, edges: plan.edges, frames };
}
```

### Step 4: Build React Flow UI

```tsx
<ReactFlowProvider>
  <ReactFlow
    nodes={flowGraph.nodes}
    edges={flowGraph.edges}
    fitView
    fitViewOptions={{ padding: 0.2 }}
    minZoom={0.5}
    maxZoom={1.5}
    nodesDraggable={false}
    nodesConnectable={false}
    snapToGrid
  >
    <Background gap={24} size={3} />
    <Panel position="top-right">
      <WorkflowToolbar executionId={executionId} />
    </Panel>
  </ReactFlow>
</ReactFlowProvider>
```

### Step 5: Add Context Providers

Create providers for workflow state management (see `components/workflow/providers.tsx` pattern).

### Step 6: Implement Chat Interface

Add a resizable sidebar with chat history and input form.

## Key Dependencies

```json
{
  "@xyflow/react": "^12.x",
  "workflow": "latest",
  "react": "^18.x"
}
```

## React Flow Best Practices

1. **Use ReactFlowProvider**: Wrap your flow in `<ReactFlowProvider>` for hooks like `useReactFlow`
2. **Memoize Node Components**: Use `memo()` to prevent unnecessary re-renders
3. **Position Calculation**: Calculate positions based on layers for clean layouts
4. **Edge Types**: Use `smoothstep` for professional-looking connections
5. **fitView Options**: Add padding (0.2) for visual breathing room
6. **Disable Interactions**: Set `nodesDraggable={false}` for display-only flows
7. **Status Animations**: Use `animated` prop on edges during execution

## Common Node Kinds

- **collect**: Gather input data or context
- **ideate**: Generate ideas or concepts
- **draft**: Create initial content
- **review**: Validate or critique
- **synthesize**: Combine multiple inputs
- **deliver**: Final output or export

## Troubleshooting

**Nodes overlap**: Increase `columnOffset` or `rowOffset` values
**Cycles in graph**: Validate edges prevent circular dependencies
**Animation too fast/slow**: Adjust delay value (default: 220ms)
**Edges not connecting**: Ensure node IDs match edge source/target exactly

## References

See [reference.md](reference.md) for React Flow API details and [examples.md](examples.md) for complete implementations.
