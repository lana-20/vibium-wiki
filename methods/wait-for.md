---
method: waitFor
aliases: [browser_wait, page.wait]
last_tested: v26.5.31
bugs: []
status: stub
---

# waitFor / browser_wait

Wait for an element to reach a given state (default: visible).

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium wait <selector> [--state visible\|hidden\|attached] [--timeout ms]` |
| MCP | `browser_wait { selector, state?, timeout? }` |
| JS | `page.wait(selector, { state?, timeout? })` |
| Python | `page.wait(selector, state=..., timeout=...)` |
| Java | `page.wait(selector, new WaitOptions().setState(...))` |

→ [[reference/api-reference]]
