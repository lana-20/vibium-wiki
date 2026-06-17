---
method: waitForFn
aliases: [browser_wait_for_fn, page.waitUntil]
last_tested: v26.5.31
bugs: [Bug1]
status: partial
---

# waitForFn / browser_wait_for_fn

Wait until a JavaScript expression returns truthy.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium wait fn "<expression>" [--timeout ms]` |
| MCP | `browser_wait_for_fn { expression, timeout? }` |
| JS | `page.waitUntil(expression, { timeout? })` |
| Python | `page.wait_until(expression, timeout=...)` |
| Java | `page.waitForFunction(expression)` |

## Known issues

**Bug 1 — FIXED v26.5.31** (#163): expression-based waits always timed out in v26.3.18 regardless of expression value. v26.5.31 wraps bare expressions uniformly so both forms work:

```ts
// Both now work in v26.5.31:
await page.waitUntil(`document.readyState === "complete"`)
await page.waitUntil(`() => document.readyState === "complete"`)
```

Java `page.waitForFunction()` has a separate double-wrap SyntaxError still open as #174. → [[bugs/java]]

→ [[methods/wait-for]] · → [[reference/api-reference]]
