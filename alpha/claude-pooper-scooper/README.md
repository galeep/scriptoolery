# claude-pooper-scooper

Cleans up orphaned [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI processes.

## The Problem

Claude Code doesn't properly clean up child processes on exit. This is a known issue with multiple bug reports spanning months:

- [#1935](https://github.com/anthropics/claude-code/issues/1935) - MCP servers not properly terminated on exit (June 2025)
- [#5545](https://github.com/anthropics/claude-code/issues/5545) - Orphaned processes causing resource drain (August 2025)
- [#11778](https://github.com/anthropics/claude-code/issues/11778) - Even `claude mcp list` leaves orphans (November 2025)

After exiting Claude Code sessions, you may find stale processes consuming CPU and memory:
- `claude` CLI processes
- MCP server processes (`mcp-server.cjs`, `chroma-mcp`)
- Subagent processes (with `--disallowedTools` flags)

## Usage

```bash
# Run after exiting Claude Code
claude-pooper-scooper
```

The script will:
1. Warn you if an active Claude session is detected
2. Report what orphaned processes it finds
3. Kill stale claude, MCP server, and subagent processes
4. Leave the claude-mem worker daemon alone (intentionally persistent)
5. Leave Claude Desktop (.app) alone
6. Log to `~/.claude_pooper_scooper/cleanup-YYYYMMDD-HHMM.log`

## Installation

```bash
cp claude-pooper-scooper ~/bin/
chmod +x ~/bin/claude-pooper-scooper
```

## Optional: Scheduled Cleanup

```bash
# Run hourly via cron
0 * * * * /path/to/claude-pooper-scooper > /dev/null 2>&1
```

## License

BSD 2-Clause (see repository root)
