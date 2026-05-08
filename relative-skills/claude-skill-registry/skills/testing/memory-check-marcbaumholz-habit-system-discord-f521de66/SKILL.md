---
name: memory-check
description: Check system memory usage, available memory, and identify cleanup opportunities. Use this skill when the user asks to check memory, RAM usage, free memory, or needs to clean up system resources.
---

# Memory Check Skill

This skill helps you check system memory usage and identify cleanup opportunities on Linux systems.

## Instructions

When activated, follow these steps to provide comprehensive memory information:

### 1. Check Overall Memory Usage

Run the `free` command to show memory and swap usage:

```bash
free -h
```

This shows:
- Total memory available
- Used memory
- Free memory
- Shared memory
- Buffer/cache memory
- Available memory (what can actually be used)
- Swap usage

### 2. Check Detailed Memory Information

For more detailed breakdown:

```bash
cat /proc/meminfo | head -20
```

This provides:
- MemTotal: Total usable RAM
- MemFree: Free RAM
- MemAvailable: Available RAM for new applications
- Buffers: Memory used for file buffers
- Cached: Memory used for caching

### 3. Check Top Memory-Consuming Processes

Show the top 10 processes consuming the most memory:

```bash
ps aux --sort=-%mem | head -11
```

This helps identify which processes are using the most memory and might be candidates for cleanup.

### 4. Check Disk Space (Related Cleanup)

Since memory cleanup often goes hand-in-hand with disk cleanup:

```bash
df -h
```

### 5. Optional: Check System Cache

To see how much memory is used by caches:

```bash
sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

**Warning**: Only suggest running this if the user explicitly wants to clear caches, as it requires sudo and will clear page cache, dentries, and inodes.

## Presenting Results

After running the commands, present the information in a clear format:

1. **Memory Summary**: Show total, used, free, and available memory
2. **Memory Percentage**: Calculate and show memory usage percentage
3. **Top Memory Users**: List the top processes consuming memory
4. **Cleanup Recommendations**: Based on the results, suggest:
   - If memory usage is high (>80%), recommend closing unnecessary applications
   - If swap is being heavily used, recommend adding more RAM or reducing memory load
   - Identify specific processes that are using excessive memory
   - Suggest disk cleanup if disk space is also low

## Examples

### Example 1: Basic Memory Check

User: "Check my memory usage"

Response: Run the commands and present:
- Total memory: 8GB
- Used: 6.2GB (77%)
- Available: 1.8GB
- Top processes: Chrome (2.1GB), Firefox (1.5GB)
- Recommendation: Memory usage is moderate. Consider closing unused browser tabs.

### Example 2: Memory Cleanup Needed

User: "My system is slow, check if I need to clean up memory"

Response: Run all commands and present:
- Memory usage: 95%
- Swap usage: 80%
- Top processes identified
- Recommendations for closing specific high-memory processes
- Suggestion to restart memory-heavy applications

## Notes

- These commands work on Linux systems (including Raspberry Pi OS)
- Some cleanup commands may require sudo privileges
- Always explain what each command does before running it
- Be careful with cache-clearing commands as they require sudo
