---
name: research/context-boundary-manager
description: Lock tasks to user-provided sources (PDF/txt/URL) by creating a per-task context container, ingesting and chunking only those sources, ranking chunks for relevance, and enforcing negative constraints against out-of-scope content. Use when strict source grounding is required.
---

# Context Boundary Manager

Capabilities
- create_context_container: initialize a per-task “notebook” that isolates supplied sources.
- ingest_local_source: parse PDF/txt/URL into chunks scoped to this container.
- calculate_relevance_score: rank chunks for a query using only container contents.
- enforce_negative_constraint: reject or strip content not present in scoped chunks.

Dependencies
- guardrails-control (scope enforcement)
- hybrid-orchestrator (flow control)
- constrained-decoding (optional stricter outputs)

Inputs
- sources: list of file paths or URLs explicitly provided by the user.
- query/task: the question to answer.
- constraints: optional allow/deny rules (keywords, domains).

Outputs
- ranked_chunks: ordered chunks with scores and source refs.
- audit trail: what was ingested, filtered, and why.

Usage
- Initialize a container, ingest sources, rank chunks, then hand results to downstream reasoning/citation-verifier. Reject any request to use out-of-container knowledge.
