# Java Client Bug Index

Last updated: 2026-06-14 · reference version: v26.5.31

## Open issues

| Issue | Title | Status |
|---|---|---|
| #174 | page.waitForFunction() always fails — Java client double-wraps every expression | open |
| #135 | page.expose() never injects function into page JS context | open |
| #128 | page.route() and page.setHeaders() cause page.go() to deadlock permanently | open |
| #106 | SelectorOptions methods not applied in element lookup (Java SDK) | open |

## Fixed in v26.5.31 (closed 2026-05-31)

| Issue | Java Bug ID | Title | Notes |
|---|---|---|---|
| #131 | B1 | page.waitForFunction() engine-side — bare expressions timed out | fixed engine-side via #163; Java client double-wrap still open (#174) |
| #129 | B2 | page.waitForURL() throws "pattern is required" | fixed |
| #130 | B4 | page.addScript()/addStyle() never execute | fixed |
| #132 | B5 | el.dispatchEvent() never triggers event handlers | fixed |
| #133 | B6 | el.highlight() throws "Unknown command" | fixed engine-side |
| #134 | B7 | el.dragTo(Element) throws "dragTo requires 'target' parameter" | fixed |
| #136 | B8 | onError()/collectErrors() never receive uncaught page errors | fixed |
| #137 | B9 | clock.setFixedTime()/pauseAt()/setSystemTime() throw "time is required" | fixed |

---

## Detail entries

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

**Same root cause as:** B3 (CLI), MB3 (MCP) — socket-level deadlock.

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
