---
method: waitURL
category: waiting
last_tested: v26.5.31
bugs: [JV-129]
status: partial
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

## Known issues

**JV-129 — partial (#129):** Java `waitForURL()` now accepts patterns (PR #167 fixed `"pattern is required"` error). Residual: `**/*.html` and `.*example.*` patterns still time out — path-separator glob and regex-style matching not evaluated correctly.

**Workaround:** use simple globs (`*example*`); avoid `**/*.html` and regex-style patterns in Java.

→ [[bugs/java#129]] · → [[reference/api-reference]]
