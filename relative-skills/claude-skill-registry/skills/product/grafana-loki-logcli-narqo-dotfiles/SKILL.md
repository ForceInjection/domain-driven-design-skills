---
name: Grafana Loki LogCLI
description: Query and explore logs in Grafana Loki via the logcli command-line tool. Use when a user asks to pull logs for analysis.
allowed-tools: Bash(logcli:*)
---

# Grafana Loki LogCLI

The logcli is a command-line client for Grafana Loki that runs LogQL queries against a Loki instance.

**Requirements**: The logcli CLI must be pre-installed on the computer.

## Instructions

When running "logcli query" *always* use `-z UTC` to request the UTC timezone of the output.

Pass the `--output raw` unless the use case requires jsonl.

When a user refers to a date or a range of dates, use the `2021-01-19T10:00:00Z` format to pass the CLI. Always assume
the time is UTC unless specified explicitly.

To request all available log entries pass the `--limit 0`. Consider pipe'ing or tee'ing the output to a temporal text file
to run the analysis on the fetched data offline.

## Examples

Run a LogQL query against the **ops Loki instance**:

```
logcli --addr=https://logs-ops-002.grafana-ops.net \
  --username=29 --password=`cat $HOME/.config/gcom/gcom-ops.token` \
  query '<query>'
```

The username "29" is the well-known "ops tenant". The API password for the tenant seats in the mentioned file.

Use the "ops" instance to pull logs for *all non-dev* workloads.

Run a LogQL query against the **dev Loki instance**:

```
logcli --addr=https://logs-dev-005.grafana-dev.net \
  --username=29 --password=`cat $HOME/.config/gcom/gcom-dev.token` \
  query '<query>'
```

Query all "info" level logs from the "compactor" container in the namespace "mimir-dev-14" between 8/10 00:00 and 9/10 00:00 (not inclusive).
Request the output in the jsonl format:

```
logcli --addr=https://logs-dev-005.grafana-dev.net \
  --username=29 --password=$(cat $HOME/.config/gcom/gcom-dev.token) \
  query '{namespace="mimir-dev-14", container="compactor"} |= `level=info`' \
  --from '2025-10-08T00:00:00Z' --to '2025-10-09T00:00:00Z' -z UTC -o jsonl --limit 0
```

## Reference

Run `logcli help` to read the reference. Running `logcli help <command>` shows the reference for a specific sub-command.

The complete online reference is available at https://grafana.com/docs/loki/latest/query/logcli/getting-started/
