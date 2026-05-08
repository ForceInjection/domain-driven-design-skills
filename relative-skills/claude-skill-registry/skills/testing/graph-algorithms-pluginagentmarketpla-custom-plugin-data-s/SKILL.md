---
name: graph-algorithms
description: Essential graph algorithms including DFS, BFS, Dijkstra shortest path, and Union-Find with production-ready implementations.
sasmp_version: "1.3.0"
bonded_agent: 03-graphs
bond_type: PRIMARY_BOND

# Production-Grade Skill Specifications (2025)
atomic_responsibility: graph_algorithm_execution
version: "2.0.0"

parameter_validation:
  strict: true
  rules:
    - name: graph
      type: dict
      required: true
    - name: start
      type: integer
      required: true
    - name: edges
      type: list
      required: false

retry_logic:
  max_attempts: 3
  backoff_ms: [100, 200, 400]
  retryable_errors:
    - timeout
    - memory_exceeded

logging_hooks:
  on_start: true
  on_complete: true
  on_error: true
  log_format: "[GRA-SKILL] {timestamp} | {operation} | {status}"

complexity_annotations:
  dfs:
    time: "O(V+E)"
    space: "O(V)"
  bfs:
    time: "O(V+E)"
    space: "O(V)"
  dijkstra:
    time: "O((V+E) log V)"
    space: "O(V)"
  union_find:
    time: "O(α(n)) per operation"
    space: "O(V)"
---

# Graph Algorithms Skill

**Atomic Responsibility**: Execute graph traversal and pathfinding algorithms efficiently.

## Graph Representation

```python
from typing import Dict, List, Set, Tuple, Optional
from collections import deque
import heapq

# Adjacency List (most common)
Graph = Dict[int, List[int]]
WeightedGraph = Dict[int, List[Tuple[int, int]]]  # node -> [(neighbor, weight)]
```

## DFS - Depth First Search

```python
def dfs_recursive(graph: Graph, start: int) -> List[int]:
    """
    DFS traversal from start node.

    Time: O(V+E), Space: O(V)

    Args:
        graph: Adjacency list representation
        start: Starting node

    Returns:
        List of nodes in DFS order
    """
    visited: Set[int] = set()
    result: List[int] = []

    def explore(node: int) -> None:
        if node in visited:
            return

        visited.add(node)
        result.append(node)

        for neighbor in graph.get(node, []):
            explore(neighbor)

    explore(start)
    return result


def dfs_iterative(graph: Graph, start: int) -> List[int]:
    """
    Iterative DFS using explicit stack.

    Use when: Avoiding recursion depth limits.
    """
    visited: Set[int] = set()
    result: List[int] = []
    stack = [start]

    while stack:
        node = stack.pop()

        if node in visited:
            continue

        visited.add(node)
        result.append(node)

        # Add neighbors in reverse for correct order
        for neighbor in reversed(graph.get(node, [])):
            if neighbor not in visited:
                stack.append(neighbor)

    return result
```

## BFS - Breadth First Search

```python
def bfs(graph: Graph, start: int) -> List[int]:
    """
    BFS traversal from start node.

    Time: O(V+E), Space: O(V)

    Use for: Shortest path in unweighted graph.
    """
    visited = {start}
    queue = deque([start])
    result: List[int] = []

    while queue:
        node = queue.popleft()
        result.append(node)

        for neighbor in graph.get(node, []):
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    return result


def shortest_path_unweighted(graph: Graph, start: int, end: int) -> int:
    """
    Find shortest path length in unweighted graph.

    Time: O(V+E), Space: O(V)

    Returns:
        Shortest distance, or -1 if no path exists
    """
    if start == end:
        return 0

    visited = {start}
    queue = deque([(start, 0)])

    while queue:
        node, distance = queue.popleft()

        for neighbor in graph.get(node, []):
            if neighbor == end:
                return distance + 1

            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, distance + 1))

    return -1  # No path found
```

## Dijkstra's Algorithm

```python
def dijkstra(graph: WeightedGraph, start: int) -> Dict[int, int]:
    """
    Single-source shortest paths with non-negative weights.

    Time: O((V+E) log V), Space: O(V)

    Args:
        graph: Weighted adjacency list {node: [(neighbor, weight)]}
        start: Source node

    Returns:
        Dictionary of shortest distances from start

    Raises:
        ValueError: If negative weight detected
    """
    distances: Dict[int, int] = {start: 0}
    pq = [(0, start)]  # (distance, node)

    while pq:
        current_dist, node = heapq.heappop(pq)

        # Skip if we've found a better path
        if current_dist > distances.get(node, float('inf')):
            continue

        for neighbor, weight in graph.get(node, []):
            if weight < 0:
                raise ValueError(f"Negative weight {weight} not allowed in Dijkstra")

            distance = current_dist + weight

            if distance < distances.get(neighbor, float('inf')):
                distances[neighbor] = distance
                heapq.heappush(pq, (distance, neighbor))

    return distances


def dijkstra_with_path(graph: WeightedGraph, start: int, end: int) -> Tuple[int, List[int]]:
    """
    Dijkstra with path reconstruction.

    Returns:
        Tuple of (distance, path) or (inf, []) if no path
    """
    distances: Dict[int, int] = {start: 0}
    predecessors: Dict[int, Optional[int]] = {start: None}
    pq = [(0, start)]

    while pq:
        current_dist, node = heapq.heappop(pq)

        if node == end:
            break

        if current_dist > distances.get(node, float('inf')):
            continue

        for neighbor, weight in graph.get(node, []):
            distance = current_dist + weight

            if distance < distances.get(neighbor, float('inf')):
                distances[neighbor] = distance
                predecessors[neighbor] = node
                heapq.heappush(pq, (distance, neighbor))

    # Reconstruct path
    if end not in distances:
        return float('inf'), []

    path = []
    current = end
    while current is not None:
        path.append(current)
        current = predecessors.get(current)

    return distances[end], path[::-1]
```

## Union-Find (Disjoint Set Union)

```python
class UnionFind:
    """
    Disjoint Set Union with path compression and union by rank.

    Time: O(α(n)) per operation (nearly constant)
    Space: O(n)

    Use for: Connected components, cycle detection, Kruskal's MST
    """

    def __init__(self, n: int):
        """Initialize n disjoint sets."""
        self.parent = list(range(n))
        self.rank = [0] * n
        self.components = n

    def find(self, x: int) -> int:
        """Find root of x with path compression."""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x: int, y: int) -> bool:
        """
        Unite sets containing x and y.

        Returns:
            True if union performed, False if already in same set
        """
        px, py = self.find(x), self.find(y)

        if px == py:
            return False

        # Union by rank
        if self.rank[px] < self.rank[py]:
            px, py = py, px

        self.parent[py] = px

        if self.rank[px] == self.rank[py]:
            self.rank[px] += 1

        self.components -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same set."""
        return self.find(x) == self.find(y)

    def get_components(self) -> int:
        """Return number of disjoint sets."""
        return self.components
```

## Topological Sort

```python
def topological_sort_kahn(n: int, edges: List[Tuple[int, int]]) -> List[int]:
    """
    Topological sort using Kahn's algorithm (BFS).

    Time: O(V+E), Space: O(V)

    Args:
        n: Number of nodes (0 to n-1)
        edges: List of (from, to) edges

    Returns:
        Topologically sorted list, or empty if cycle exists
    """
    graph: Graph = {i: [] for i in range(n)}
    in_degree = [0] * n

    for src, dst in edges:
        graph[src].append(dst)
        in_degree[dst] += 1

    queue = deque([i for i in range(n) if in_degree[i] == 0])
    result: List[int] = []

    while queue:
        node = queue.popleft()
        result.append(node)

        for neighbor in graph[node]:
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    # Check for cycle
    if len(result) != n:
        return []  # Cycle detected

    return result
```

## Unit Test Template

```python
import pytest

class TestGraphAlgorithms:
    """Unit tests for graph algorithm implementations."""

    @pytest.fixture
    def simple_graph(self):
        return {0: [1, 2], 1: [3], 2: [3], 3: []}

    @pytest.fixture
    def weighted_graph(self):
        return {0: [(1, 4), (2, 1)], 1: [(3, 1)], 2: [(1, 2), (3, 5)], 3: []}

    def test_dfs(self, simple_graph):
        result = dfs_recursive(simple_graph, 0)
        assert 0 in result and 3 in result
        assert result.index(0) < result.index(3)

    def test_bfs_shortest_path(self, simple_graph):
        assert shortest_path_unweighted(simple_graph, 0, 3) == 2

    def test_dijkstra(self, weighted_graph):
        distances = dijkstra(weighted_graph, 0)
        assert distances[3] == 4  # 0->2->1->3 = 1+2+1

    def test_union_find(self):
        uf = UnionFind(5)
        uf.union(0, 1)
        uf.union(2, 3)
        assert uf.connected(0, 1)
        assert not uf.connected(0, 2)
        assert uf.get_components() == 3

    def test_topological_sort(self):
        result = topological_sort_kahn(4, [(0, 1), (0, 2), (1, 3), (2, 3)])
        assert result.index(0) < result.index(1)
        assert result.index(0) < result.index(2)
```

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Infinite loop | Not marking visited | Add node to visited before enqueueing |
| Wrong shortest path | Using DFS instead of BFS | BFS for unweighted, Dijkstra for weighted |
| Negative weights fail | Dijkstra limitation | Use Bellman-Ford instead |
| Memory exceeded | Dense graph | Use adjacency list, not matrix |

### Debug Checklist
```
□ Visited set initialized correctly?
□ All neighbors processed?
□ Graph representation matches algorithm?
□ Edge cases: empty graph, disconnected?
□ Cycle detection needed?
□ 0-indexed vs 1-indexed nodes?
```
