# Vibium API Surface — Counts & Interfaces

Last verified: v26.5.31 · 2026-06-01

## Method / command counts

| Interface | Count | Description |
|---|---|---|
| CLI | 66 commands | `vibium <command>` — daemon-backed, shell-driven |
| MCP | 85 tools | `browser_*` — JSON-RPC, agent-driven |
| JavaScript / TypeScript API | 68 methods | `page.*`, `element.*`, async + sync |
| Python API | 72 methods | `page.*`, `element.*`, async + sync |
| Java API | 82 methods | `Page`, `Element`, `Browser` classes |

MCP has more tools than CLI (85 vs 66) because some operations map to multiple MCP tools (e.g. mouse, touch, dialog variants are split out).

Python and Java have more methods than JS (72/82 vs 68) because they wrap more type-level variants explicitly.

## Install links

| Interface | Package | Link |
|---|---|---|
| CLI | npm | https://www.npmjs.com/package/vibium |
| JavaScript / TypeScript | npm `vibium` | https://www.npmjs.com/package/vibium |
| Python | PyPI `vibium` | https://pypi.org/project/vibium/ |
| Java | Maven / Gradle `com.vibium:vibium` | https://mvnrepository.com/artifact/com.vibium/vibium/ |

## Interface categories

### CLI (66 commands) — 8 categories per vibewire Issue 01

- Navigation: go, back, forward, reload, wait
- Page reading: title, url, text, html, screenshot, pdf
- Elements: find, map, a11y-tree, highlight, diff
- Interaction: click, dblclick, hover, fill, type, select, check, uncheck, upload, drag
- Input: keys, press, mouse, scroll, focus
- State: storage, cookies, geolocation, viewport, window, media, frame, frames
- Async: sleep, eval, content, serve, record, page, pages
- Daemon: daemon start/stop/status, pipe, ws-test, bidi-test, launch-test, completion

### MCP (85 tools) — 8 categories per vibewire Issue 02

85 tools across 8 sections — includes all CLI operations plus additional tools for:
- `browser_start` / `browser_stop` (no daemon concept in MCP)
- `browser_set_content` (inline HTML injection)
- `browser_a11y_tree` (accessibility tree)
- `browser_diff_map` (visual diff)
- `browser_record_*` (recording with chunk/group controls)
- `browser_wait_for_*` (url, text, fn, load — explicit waits)
- `browser_mouse_*` (mouse_click, mouse_move, mouse_down, mouse_up separate tools)
- `browser_emulate_media`

### JavaScript / TypeScript API (68 methods) — per vibewire Issue 03

`page.*` + `element.*` — async and sync variants. Key classes: `Browser`, `BrowserContext`, `Page`, `Element`, `Clock`, `Dialog`, `Download`, `Route`, `Recording`, `Keyboard`, `Mouse`.

### Python API (72 methods) — per vibewire Issue 04

`page.*` + `element.*` + `browser.*` — async (`async_api`) and sync (`sync_api`). Same underlying BiDi client. `element.bounds()` returns `BoundingBox` dataclass (supports both attribute and dict-style access since v26.5.31 — #147).

### Java API (82 methods) — per vibewire Issue 05

`Page`, `Element`, `Browser`, `BrowserContext`, `Clock`, `Dialog`, `Download`, `Route`, `Recording`, `Keyboard`, `Mouse`, `Touch` classes. All blocking (no async). Error types: `VibiumException`, `VibiumTimeoutException`, `VibiumNotFoundException`, `VibiumConnectionException`, `ElementNotFoundException`, `BrowserCrashedException`.

## MCP vs CLI comparison

Key asymmetries per vibewire Issue 06 (27 paired comparisons documented):

- MCP has `browser_wait_for_*` family (url, text, fn, load as separate tools); CLI uses `vibium wait` with subcommands
- MCP has `browser_set_content`; CLI uses `vibium content`
- MCP `browser_start` / `browser_stop` are explicit; CLI uses a persistent daemon
- 50+ MCP-only tools with no direct CLI equivalent
- 14 behaviors identical across both interfaces

→ [[reference/public-docs]] · → [[reference/api-reference]]
