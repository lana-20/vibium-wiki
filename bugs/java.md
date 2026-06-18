# Java Client Bug Index

Last updated: 2026-06-17 · reference version: v26.5.31

## Open issues

| Issue | Title | Status |
|---|---|---|
| #174 | page.waitForFunction() always fails — Java client double-wraps every expression | open |
| #135 | page.expose() never injects function into page JS context | open |
| #128 | page.route() and page.setHeaders() cause page.go() to deadlock permanently | open |
| #106 | SelectorOptions methods not applied in element lookup (Java SDK) | open |

## Partial fixes in v26.5.31

Core parameter mismatches resolved by PR #167 (merged 2026-05-31 by Jason Huggins / @hugs into VibiumDev/vibium main, shipped in v26.5.31). Hardening suite found residual failures in specific cases.

| Issue | Java Bug ID | Title | What was fixed | What still fails |
|---|---|---|---|---|
| #129 | B2 | page.waitForURL() pattern matching | `"pattern is required"` error gone; exact URLs + simple globs work | `**/*.html` and `.*example.*` patterns time out |
| #130 | B4 | page.addScript()/addStyle() never execute | Param key corrected; `setContent→addScript→evaluate` works | `addScript→go()` path — script still null after navigation |
| #136 | B8 | onError()/collectErrors() | `setTimeout` errors + uncaught script errors now captured | `ErrorEvent` dispatched via JS + unhandled `Promise.reject` still not captured |
| #137 | B9 | clock.setFixedTime()/pauseAt()/setSystemTime() | ISO-8601 and epoch-ms string args now accepted | `ClockOptions.time()` builder path still ignored |

## Fixed in v26.5.31 (closed 2026-05-31)

| Issue | Java Bug ID | Title | Notes |
|---|---|---|---|
| #131 | B1 | page.waitForFunction() engine-side — bare expressions timed out | fixed engine-side via #163; Java client double-wrap still open (#174) |
| #132 | B5 | el.dispatchEvent() never triggers event handlers | fixed |
| #133 | B6 | el.highlight() throws "Unknown command" | fixed engine-side |
| #134 | B7 | el.dragTo(Element) throws "dragTo requires 'target' parameter" | fixed |

---

## Detail entries

### #129 — page.waitForURL() pattern matching · partial

**Fixed:** `"pattern is required"` error resolved in PR #167 (commit ba845474). Java client was sending `"url"` key; engine reads `"pattern"`. Parameter plumbing now correct.

**Still failing (v26.5.31):**
```java
page.go("https://example.com/index.html");
page.waitForURL("**/*.html", new WaitOptions().timeout(4000));
// VibiumTimeoutException — path-separator glob not evaluated correctly

page.go("https://example.com");
page.waitForURL(".*example.*", new WaitOptions().timeout(4000));
// VibiumTimeoutException — regex-style pattern not evaluated correctly
```

**Pattern status after fix:**

| Pattern | Status |
|---|---|
| `"https://example.com"` | ✅ PASS |
| `"https://example.com/"` | ✅ PASS |
| `"*example*"` | ✅ PASS |
| `"**example**"` | ✅ PASS |
| `"https://**"` | ✅ PASS |
| `"**/*.html"` | ❌ still fails (timeout) |
| `".*example.*"` | ❌ still fails (timeout) |

**Workaround:** poll `page.url()` manually, or use `*example*` glob form where possible.

---

### #130 — page.addScript()/addStyle() · partial

**Fixed:** Java client was sending `"source"` key; engine reads `"url"` or `"content"`. PR #167 corrects the key based on whether the arg is a URL. `setContent → addScript → evaluate` path now works.

**Still failing (v26.5.31):** `addScript → go()` — script injected before navigation is null after `go()` completes. The engine does not re-inject scripts on navigation.

```java
page.addScript("https://cdn.example.com/lib.js");
page.go("https://example.com");
page.evaluate("typeof window.myLib");  // → "undefined"
```

**Workaround:** inject after navigation via `page.evaluate()` with the script content directly.

---

### #136 — onError()/collectErrors() · partial

**Fixed:** `log.entryAdded` events were always routed to the console handler. PR #167 now routes by `"type"` field: `"javascript"` → error handler, else console. Uncaught script errors and `setTimeout`-thrown errors are now captured.

**Still failing (v26.5.31):** `ErrorEvent` dispatched via `dispatchEvent(new ErrorEvent(...))` and unhandled `Promise.reject` are not delivered to the error handler.

```java
// These still not captured:
page.evaluate("window.dispatchEvent(new ErrorEvent('error', { message: 'dispatched' }))");
page.evaluate("Promise.reject(new Error('unhandled'))");
```

---

### #137 — clock methods · partial

**Fixed:** `clock.setFixedTime()`, `pauseAt()`, `setSystemTime()` were sending time as a string; engine reads epoch-milliseconds (number). PR #167 normalizes ISO-8601 strings and epoch-ms strings to a number. Direct string args now work.

**Still failing (v26.5.31):** `ClockOptions.time()` builder path — the time value set via the options object is not forwarded.

```java
page.clock.install(new ClockOptions().time("2024-01-01T00:00:00.000Z"));
// clock not frozen — Date.now() returns live system time

// Workaround — pass time directly:
page.clock.install();
page.clock.setFixedTime("2024-01-01T00:00:00.000Z");  // ✅ works
```

---

### #174 — page.waitForFunction() Java double-wraps (open)

**History:** #131 reported waitForFunction always timing out. Engine fix (#163, PR #163) was included in v26.5.31 — engine no longer double-wraps. However, the **Java client** independently wraps every expression into `() => <expr>` before sending. Since the engine also wraps, both bare strings and arrow functions arrive double-wrapped → `SyntaxError: Unexpected token ')'`.

The Java client bug (#174) is distinct from and not fixed by the engine fix.

**Symptom:**
```java
page.waitForFunction("true", new WaitOptions().timeout(3000));
// → VibiumTimeoutException: last error: SyntaxError: Unexpected token ')'
page.waitForFunction("() => true", new WaitOptions().timeout(3000));
// → same SyntaxError
```

**Tracked in:** vibium-java-test as Java B3.

---

### #128 — page.route() / page.setHeaders() navigation deadlock (open)

`page.setHeaders()` or `page.route()` cause `page.go()` to hang permanently — server-side network interception blocks navigation at the BiDi layer.

**Same root cause as:** B3 (CLI), #151 (MCP) — socket-level deadlock.

**Workaround:** avoid `setHeaders`/`route` before navigation. Use `page.evaluate()` for header injection patterns where possible.

→ [[patterns/dialog_deadlock]]

---

### #135 — page.expose() never injects function (open)

`page.expose("myFn", callback)` registers the callback server-side but the function never appears in the page's JS context. `window.myFn` is always `undefined` after expose. No error raised.

---

### #106 — SelectorOptions not applied (open)

`page.find(new SelectorOptions().text("Login").role("button"))` — the options chain is not forwarded to the engine. The lookup falls back to the first argument only.

---

## Notes on the vibium-java-test suite

Java API regression suite: 140 pass / 22 skip on v26.5.31.  
Bug hardening suite: B1–B10 across 6 sites.  
Repo: github.com/lana-20/vibium-java-test  
Bug #174 filed with double-wrap SyntaxError repro.  
