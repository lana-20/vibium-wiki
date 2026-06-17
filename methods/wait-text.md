---
method: waitText
category: waiting
last_tested: v26.5.31
bugs: []
status: stub
---

# waitText / browser_wait_for_text

Wait until a given text string appears on the page.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium wait text "<text>" [--timeout ms]` |
| MCP | `browser_wait_for_text { text, timeout? }` |
| JS | `page.waitUntil.text(text)` |
| Python | `page.wait_until.text(text)` |
| Java | `page.waitUntilText(text)` |

→ [[reference/api-reference]]
