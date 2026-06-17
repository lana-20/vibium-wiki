---
method: wait / waitUntil
aliases: [browser_wait, browser_wait_for_fn, browser_wait_for_url, browser_wait_for_text, browser_wait_for_load, page.wait, page.waitUntil]
last_tested: v26.5.31
last_tested_date: 2026-06-06
bugs: [Bug1]
status: partial
---

# wait / waitUntil

Wait for a condition before continuing.

## CLI

```sh
vibium wait ".selector"          # wait for element
vibium wait url "/dashboard"     # wait for URL substring
vibium wait text "Success"       # wait for visible text
vibium wait load                 # wait for page load event
vibium sleep 500                 # fixed delay (ms)
```

## JS API

```ts
await page.wait(500)                              // fixed ms
await page.waitUntil.url('dashboard')             // URL contains substring
await page.waitUntil.loaded()                     // page load event
await page.waitUntil(expression, { timeout })     // JS expression — see Bug 1
```

## MCP tools

```
browser_wait          { selector }
browser_wait_for_url  { url }
browser_wait_for_text { text }
browser_wait_for_load {}
browser_wait_for_fn   { expression }
browser_sleep         { ms }
```

---

## Bug 1 — waitUntil(expression) always times out · **FIXED v26.5.31** (#123, #163)

**Affected:** JS client `page.waitUntil(expression)`, Python `page.wait_until(expression)`, Java `page.waitForFunction(expression)` — all expression-based waits.

**Trigger (v26.3.18):** any bare expression string timed out regardless of its value:

```ts
// document.readyState === "complete" on a loaded page — should resolve instantly
await page.waitUntil(`document.readyState === "complete"`, { timeout: 5000 })
// → throws: "timeout waiting for function to return truthy"
```

**Unaffected:** `page.waitUntil.url()`, `page.waitUntil.loaded()`, `page.wait(ms)` all worked correctly.

**Fix:** v26.5.31 PR #163 wraps bare expressions uniformly alongside arrow functions. Now both forms work:
- `"document.readyState === 'complete'"` — bare expression ✅
- `"() => document.readyState === 'complete'"` — arrow function ✅

**Workaround** (for v26.3.18): replace expression waits with `page.wait(ms)` fixed delays. Timing must be determined empirically.

**Related:** Java `page.waitForFunction()` had a separate variant of this — double-wrapped SyntaxError filed as #174 (still open for Java). → [[bugs/java]]

→ [[bugs/js#Bug1]] · → [[methods/evaluate]]
