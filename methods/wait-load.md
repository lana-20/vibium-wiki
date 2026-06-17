---
method: waitLoad
category: waiting
last_tested: v26.5.31
bugs: []
status: stub
---

# waitLoad / browser_wait_for_load

Wait until the page load event fires.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium wait load [--timeout ms]` |
| MCP | `browser_wait_for_load { timeout? }` |
| JS | `page.waitUntil.loaded()` |
| Python | `page.wait_until.loaded()` |
| Java | `page.waitUntilLoaded()` |

→ [[reference/api-reference]]
