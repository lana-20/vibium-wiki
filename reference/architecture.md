# Architecture

Source: `README.md`, `docs/explanation/sync-async-client-architecture.md`, `docs/explanation/webdriver-bidi.md`

---

## System diagram

```
┌──────────────────────────────────────┐
│             LLM / Agent              │
│  (Claude Code, Codex, Gemini, etc.)  │
└──────────────────────────────────────┘
       ▲                  ▲
       │ CLI (Bash)       │ MCP (stdio)
       ▼                  ▼
┌───────────────────────────────────┐
│          Vibium binary            │
│                                   │
│  ┌──────────────┐ ┌────────────┐  │
│  │ CLI Commands │ │ MCP Server │  │
│  └─────┬────────┘ └──────┬─────┘  │        ┌──────────────────┐
│        └───────▲─────────┘        │        │                  │
│                │                  │        │  Chrome Browser  │
│         ┌──────▼───────┐          │  BiDi  │                  │
│         │  BiDi Proxy  │          │◄──────►│                  │
│         └──────────────┘          │        └──────────────────┘
└───────────────────────────────────┘
          ▲
          │ WebSocket BiDi :9515
          ▼
┌──────────────────────────────────────┐
│          Client Libraries            │
│       (js/ts | python | java)        │
│                                      │
│  ┌─────────────────┐ ┌────────────┐  │
│  │   Async API     │ │  Sync API  │  │
│  │ await vibe.go() │ │  vibe.go() │  │
│  └─────────────────┘ └────────────┘  │
└──────────────────────────────────────┘
```

---

## Components

### The binary (`clicker/`)

Single ~10MB Go binary. Runs as:
- **CLI daemon**: persistent process, socket-based, `vibium go ...`
- **MCP server**: stdio JSON-RPC, `vibium mcp`
- **Direct WebSocket server**: client libraries connect on `:9515`

All three modes share the same BiDi proxy and handler logic under `clicker/internal/api/`.

### CLI daemon vs MCP session

| Aspect | CLI | MCP |
|---|---|---|
| Lifecycle | persistent daemon — survives between commands | per-session — `browser_start` / `browser_stop` |
| Interface | Bash subcommands | JSON-RPC tool calls |
| Commands/tools | 66 | 85 |
| Dialog deadlock | B3 (deferred) | #151 (deferred) |
| Obscured check | unaffected | MB10 (intermittent) |

### Client libraries

Connect to the binary's WebSocket on `:9515`. All languages expose the same object model:
`Browser` → `BrowserContext` → `Page` → `Element`

Each library provides both **async** and **sync** APIs. The sync API is implemented via a worker-thread + `SharedArrayBuffer + Atomics.wait()` bridge (JS) or equivalent blocking layer (Python/Java).

---

## Sync/async bridge (JS client)

The JS sync API does not call a smaller model or simplified path — it runs the full async API on a worker thread and blocks the main thread with `Atomics.wait`. This means:

- No `await` anywhere in sync code
- Worker thread holds all live browser objects (Page, Element)
- Main thread communicates via integer registry IDs
- Callbacks (route handlers, dialog handlers) flow back to the main thread via `signal[0] = 2` + a `MessagePort`

**Key constraint:** `SharedArrayBuffer` requires Node.js 16+ and cross-origin isolation headers if used in a browser context (this is Node-only).

**Signal protocol:**

| `signal[0]` value | Meaning |
|---|---|
| `0` | idle |
| `1` | worker result ready |
| `2` | worker needs main-thread callback |

**Critical ordering rule:** reset `signal[0]` to `0` BEFORE posting a callback decision back. If you reset after, the worker may prepare the next callback and set `signal[0] = 2` before your reset, overwriting it to `0` and causing a deadlock.

→ Full details: `clients/javascript/src/sync/bridge.ts`, `clients/javascript/src/sync/worker.ts`

---

## WebDriver BiDi foundation

Vibium is built on [WebDriver BiDi](https://w3c.github.io/webdriver-bidi/), a W3C standard. All browser communication goes through WebSockets with bidirectional JSON-RPC:

- **Client → browser**: `{"id":1,"method":"browsingContext.navigate","params":{"url":"..."}}`
- **Browser → client**: `{"id":1,"result":{"url":"..."}}`  
- **Browser → client (push)**: `{"method":"log.entryAdded","params":{...}}` (no `id`)

Unlike HTTP WebDriver (request/response only), BiDi enables real-time events: console logs, network requests, DOM changes pushed as they happen.

**Coverage status:** 40 of 87 BiDi commands/events implemented → [[reference/bidi-coverage]]

**Key BiDi → Vibium mappings:**

| BiDi concept | Vibium equivalent |
|---|---|
| `session.new` | `browser.start()` |
| `browser.createUserContext` | `browser.newContext()` |
| `browsingContext.create` | `browser.newPage()` |
| `browsingContext.navigate` | `page.go(url)` |
| `browsingContext.locateNodes` | `page.find()` |
| `script.callFunction` | `page.evaluate()` |
| `network.addIntercept` | `page.route()` |
| `browsingContext.handleUserPrompt` | `dialog.accept()` / `dialog.dismiss()` |

---

## Platform support

| Platform | Architecture | Status |
|---|---|---|
| Linux | x64 | Supported |
| macOS | x64 (Intel) | Supported |
| macOS | arm64 (Apple Silicon) | Supported |
| Windows | x64 | Supported |

---

## Install paths

Chrome for Testing is downloaded to a platform-specific cache:

| Platform | Default cache path |
|---|---|
| Linux | `~/.cache/vibium/` |
| macOS | `~/Library/Caches/vibium/` |
| Windows | `%LOCALAPPDATA%\vibium\` |

Override with `VIBIUM_CACHE_DIR`. Skip download with `VIBIUM_SKIP_BROWSER_DOWNLOAD=1`.

→ [[reference/api-surface]] · → [[reference/bidi-coverage]] · → [[reference/actionability]]
