---
method: onError
category: events
last_tested: v26.5.31
bugs: [JV-136]
status: partial
---

# onError

Error event listener.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | — |
| MCP | — |
| JS | `page.onError()` |
| Python | `page.on_error()` |
| Java | `page.onError(cb)` |

## Known issues

**JV-136 — partial (#136):** Java `onError()` event routing fixed (PR #167). Residual: `ErrorEvent` dispatched via JS and unhandled `Promise.reject` still not captured. Only `setTimeout`-thrown errors and uncaught script errors are delivered.

**Workaround:** none for `ErrorEvent`/`Promise.reject`; use try/catch or evaluate-based guards.

→ [[bugs/java#136]] · → [[reference/api-reference]]
