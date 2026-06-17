---
method: waitURL
category: waiting
last_tested: v26.5.31
bugs: []
status: stub
---

# waitURL / browser_wait_for_url

Wait until the current URL contains a given substring.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium wait url "<pattern>" [--timeout ms]` |
| MCP | `browser_wait_for_url { url, timeout? }` |
| JS | `page.waitUntil.url(pattern)` |
| Python | `page.wait_until.url(pattern)` |
| Java | `page.waitUntilUrl(pattern)` |

→ [[reference/api-reference]]
