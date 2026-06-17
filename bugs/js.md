# JS Client Bug Index

Last run: v26.5.31 · 2026-06-06  
Repro repo: github.com/lana-20/vibium-test-js  
Test suite: 127 PASS / 1 BUG / 0 FAIL on v26.5.31 (was 125/3/0 on v26.3.18)

| gh Issue | Method | Status (v26.5.31) | Workaround |
|---|---|---|---|
| [#123](https://github.com/VibiumDev/vibium/issues/123) | `page.waitUntil` | fixed v26.5.31 (PR #163) | was: `page.wait(ms)` |
| [#124](https://github.com/VibiumDev/vibium/issues/124) | `page.evaluate` | open | JSON.stringify wrap |
| [#125](https://github.com/VibiumDev/vibium/issues/125) | `page.clock` | fixed v26.5.31 (PR #163) | was: always call install() first |
| [#126](https://github.com/VibiumDev/vibium/issues/126) | `page.capture.navigation`, `page.url` | open | poll url() or use evaluate('location.href') |
| [#118](https://github.com/VibiumDev/vibium/issues/118) | `page.find`, `page.findAll` | open (enhancement) | evaluate() with shadowRoot.querySelector |

---

## #123 — waitUntil(expression) always times out · **FIXED v26.5.31** (PR #163)

**Trigger:** `page.waitUntil(expression, opts)` threw timeout even for immediately-true expressions (e.g. `document.readyState === "complete"` on a loaded page). `page.waitUntil.url()` was unaffected.

**Root cause:** the engine only accepted arrow functions — bare expressions like `document.readyState === "complete"` were never evaluated.

**Fix:** v26.5.31 PR #163 now wraps bare expressions uniformly. Regression tests un-skipped and passing.

**Repro (pre-fix, for regression tracking):**
```ts
await page.go('https://the-internet.herokuapp.com/shadowdom')
await page.waitUntil(`document.readyState === "complete"`, { timeout: 5000 })
// Before fix: throws "timeout waiting for function to return truthy"
// After fix: resolves immediately
```

**Workaround** (was needed on v26.3.18): `await page.wait(ms)` with empirically-chosen delay.

→ `tests/repro-bug1-waituntil-expression.test.ts` · → [[bugs/js#123]]

---

## #124 — evaluate() wraps nested string[][] as BiDi typed objects · open

**Trigger:** `page.evaluate()` returning a nested array (`string[][]`) — inner array items deserialize as `{ type: "string", value: "..." }` instead of plain strings. A flat `string[]` deserializes correctly.

```ts
// Flat — works
const modes = await page.evaluate<string[]>(
  `[...document.querySelectorAll('my-paragraph')].map(h => h.shadowRoot.mode)`
)
// modes[0] === "open" ✓

// Nested — broken
const items = await page.evaluate<string[][]>(
  `[...document.querySelectorAll('my-paragraph')].map(h => [...h.shadowRoot.children].map(c => c.tagName))`
)
// items[0][0] === { type: "string", value: "STYLE" }  ← BUG
// Expected:       "STYLE"
```

**Root cause:** BiDi result deserializer unwraps the outermost remote value but does not recursively unwrap primitive values inside nested arrays.

**Workaround** — round-trip via JSON:
```ts
const json = await page.evaluate<string>(
  `JSON.stringify([...document.querySelectorAll('my-paragraph')].map(h => [...h.shadowRoot.children].map(c => c.tagName)))`
)
const items = JSON.parse(json) as string[][]
// items[0][0] === "STYLE" ✓
```

**Affects:** JS, Python, Java clients (same BiDi deserializer path). CLI returns JSON string (B9 fixed) so JSON.parse workaround works there already.

→ `tests/repro-bug2-evaluate-nested-array.test.ts` · → [[bugs/js#124]] · → [[methods/evaluate]]

---

## #125 — clock.setFixedTime() silently fails without clock.install() · **FIXED v26.5.31** (PR #163)

**Trigger:** Calling `page.clock.setFixedTime(time)` without first calling `page.clock.install()` had no effect — `Date.now()` returned live system time. No error thrown.

**Root cause:** Go handler evaluated `window.__vibiumClock.setFixedTime(time)` but `__vibiumClock` is only injected by `clock.install()`. Without it, the eval threw a ReferenceError that was silently swallowed.

**Fix:** v26.5.31 now returns a clear error: `"clock not installed: call clock.install() before clock.setFixedTime()"`. Standalone `setFixedTime()` (without `install()`) is still not supported — the fix adds an error guard, not standalone support.

**Note:** Playwright's `page.clock.setFixedTime()` works standalone. Vibium requires `install()` first.

**Workaround** (was needed on v26.3.18):
```ts
await page.clock.install({ time: '2024-01-01T00:00:00.000Z' })
await page.clock.setFixedTime('2020-01-01T00:00:00.000Z')
const ts = await page.evaluate<number>('Date.now()')
// ts === 1577836800000 ✓
```

→ `tests/repro-bug3-clock-setfixedtime.test.ts` · → [[bugs/js#125]] · → [[methods/clock]]

---

## #126 — capture.navigation() / page.url() miss SPA pushState · open

Full detail in [[methods/navigate#126]].

**Summary:** `capture.navigation()` times out and `page.url()` goes stale on SPAs using `history.pushState()`. Full-page navigations are unaffected.

**Root cause:** Go binary only subscribes to `browsingContext.load` and `browsingContext.fragmentNavigated`. `pushState` fires neither — requires `browsingContext.historyUpdated` (Chrome 123+).

**Workaround:**
```ts
const urlBefore = await page.url()
await page.find({ role: 'link', text: 'Button Demo' }).click()
await page.wait(500)
const urlAfter = await page.evaluate<string>('location.href')  // always current
```

→ `tests/repro-bug4-spa-navigation.test.ts` · → [[methods/navigate]]

---

## Enhancement — Pierce selector for shadow DOM · open (#118) {#118}

Full detail in [[methods/find#shadow-dom]].

**Summary:** `page.find()` and `page.findAll()` do not cross shadow boundaries. No pierce combinator (`>>` / `>>>`) supported. All shadow DOM access requires `page.evaluate()` with manual `shadowRoot.querySelector` traversal.

**Workaround:**
```ts
const text = await page.evaluate<string>(
  `document.querySelector('my-paragraph').shadowRoot.querySelector('p').textContent.trim()`
)
```

→ `tests/repro-enhancement-shadow-pierce.test.ts` · → [[methods/find]]

---

## Network teardown race — unhandled rejection in api-network tests

After all network tests pass, an unhandled rejection fires: `timeout: session closed`. This is a race in the BiDi layer during test teardown, not a test failure. Tests should be reported as PASS, not FAIL.

→ `tests/api-network.test.ts` (teardown)
