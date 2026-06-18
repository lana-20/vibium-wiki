# Getting Started — MCP Server

Source: `docs/tutorials/getting-started-mcp.md`

---

## Quick setup

**Claude Code:**
```bash
claude mcp add vibium -- npx -y vibium mcp
```

**Gemini CLI:**
```bash
gemini mcp add vibium npx -y vibium mcp
```

Chrome downloads automatically on first use.

---

## Try it

Restart your AI assistant, then ask:
```
Take a screenshot of https://example.com
```

The AI controls a real browser via Vibium's 85 MCP tools (e.g., `browser_navigate`, `browser_screenshot`, `browser_click`).

---

## Options

### Custom screenshot directory
```bash
claude mcp add vibium -- npx -y vibium mcp --screenshot-dir ./screenshots
# disable file saving (base64 inline only):
claude mcp add vibium -- npx -y vibium mcp --screenshot-dir ""
```

### Headless mode
```bash
claude mcp add vibium -- npx -y vibium mcp --headless
```

### Local binary
```bash
claude mcp add vibium -- /path/to/vibium mcp
```

### Manual JSON config (Gemini CLI)
`~/.gemini/settings.json` or `.gemini/settings.json` in project:
```json
{
  "mcpServers": {
    "vibium": {
      "command": "npx",
      "args": ["-y", "vibium", "mcp"]
    }
  }
}
```

### Remove
```bash
claude mcp remove vibium
gemini mcp remove vibium
```

---

## Troubleshooting

| Issue | Fix |
|---|---|
| Changes not taking effect | Tool discovery happens on startup — restart the AI session |
| Chrome fails to download | Run `npx -y vibium install` |
| Gatekeeper warning (macOS) | `xattr -cr "$(npx -y vibium which chromedriver)"` |
| Verify server works | `echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{}}}' \| npx -y vibium mcp` — should respond with `serverInfo` |

---

## CLI vs MCP — key differences

| | CLI | MCP |
|---|---|---|
| Browser lifecycle | Persistent daemon | Explicit `browser_start` / `browser_stop` |
| Count | 66 commands | 85 tools |
| Dialog deadlock | B3 (deferred) | #151 (deferred) |
| Obscured false-positive | Unaffected | MB10 (intermittent, sticky nav) |
| Cost | Cheaper (recommended) | 4.4× more costly in benchmarks |
| Speed | 6.3× faster | Slower |

→ [[reference/api-surface]] · → [[bugs/mcp]] · → [[guides/getting-started-js]]
