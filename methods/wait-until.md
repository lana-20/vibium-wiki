---
method: waitUntil
category: waiting
last_tested: v26.5.31
bugs: [Bug1, JS-123]
status: partial
---

# waitUntil

General-purpose condition wait; dispatches to url / loaded / text / expression variants.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium wait <selector\|url\|text\|load\|fn>` |
| MCP | `browser_wait · browser_wait_for_url · browser_wait_for_text · browser_wait_for_load · browser_wait_for_fn` |
| JS | `page.waitUntil(expression)` / `page.waitUntil.url()` / `.loaded()` / `.text()` |
| Python | `page.wait_until(expression)` / `page.wait_until.url()` / `.loaded()` / `.text()` |
| Java | `page.waitForFunction()` / `page.waitUntilUrl()` / `page.waitUntilLoaded()` |

## Known issues

**Bug 1 — FIXED v26.5.31**: expression-based form `page.waitUntil(expression)` always timed out in v26.3.18. Fixed in #163. → [[methods/wait-for-fn]]

→ [[reference/api-reference]]
