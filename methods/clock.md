---
method: clock
aliases: [page_clock_install, page_clock_fast_forward, page_clock_set_fixed_time, page.clock]
last_tested: v26.5.31
last_tested_date: 2026-06-06
bugs: [Bug3]
status: partial
---

# clock

Control browser time (fake timers, freeze Date.now, timezone).

## API

```ts
// JS
await page.clock.install({ time: '2024-01-01T00:00:00.000Z' })
await page.clock.setFixedTime('2020-01-01T00:00:00.000Z')
await page.clock.fastForward(1000)   // advance by 1s
await page.clock.runFor(5000)        // run timers for 5s
await page.clock.pauseAt(time)
await page.clock.resume()
await page.clock.setSystemTime(time)
await page.clock.setTimezone('America/New_York')
```

```sh
# CLI
vibium clock install
vibium clock set-fixed-time "2024-01-01T00:00:00.000Z"
vibium clock fast-forward 1000
vibium clock run-for 5000
vibium clock pause-at "2024-01-01"
vibium clock resume

# MCP
page_clock_install
page_clock_set_fixed_time
page_clock_fast_forward
page_clock_run_for
page_clock_pause_at
page_clock_resume
page_clock_set_system_time
page_clock_set_timezone
```

---

## Bug 3 — setFixedTime() silently fails without prior install() · **FIXED v26.5.31** (#125, #163)

**Trigger (v26.3.18):** Calling `page.clock.setFixedTime(time)` without first calling `page.clock.install()` had no observable effect. `Date.now()` continued returning live system time. No error thrown.

```ts
await page.go('https://testtrack.org')
await page.clock.setFixedTime('2020-01-01T00:00:00.000Z')
const ts = await page.evaluate<number>('Date.now()')
// Expected: 1577836800000
// Actual:   ~1777686857749 (live system time)
```

**Root cause:** Go handler evaluated `window.__vibiumClock.setFixedTime(time)`. `__vibiumClock` is only injected by `clock.install()` — without it the eval threw a ReferenceError that was silently swallowed.

**Fix:** v26.5.31 now returns `"clock not installed: call clock.install() before clock.setFixedTime()"` instead of silently succeeding.

**Important:** Standalone `setFixedTime()` (without `install()`) is still NOT supported. The fix adds an error guard only. Playwright supports standalone `setFixedTime()` — Vibium does not.

**Required pattern (all versions):**
```ts
await page.clock.install({ time: '2024-01-01T00:00:00.000Z' })
await page.clock.setFixedTime('2020-01-01T00:00:00.000Z')
const ts = await page.evaluate<number>('Date.now()')
// ts === 1577836800000 ✓
```

Note: `clock.*` tests use `testtrack.org` as host (neutral, no page-specific timers).

→ [[bugs/js#Bug3]]
