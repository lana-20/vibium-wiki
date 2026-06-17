---
method: cl-inst
aliases: [page_clock_install, page.clock.install]
last_tested: v26.5.31
last_tested_date: 2026-06-06
bugs: [JS-125]
status: partial
---

# cl-inst / clock.install

Install fake timers and freeze browser time. Must be called before any other clock method.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium clock install` |
| MCP | `page_clock_install {}` |
| JS | `page.clock.install({ time? })` |
| Python | `page.clock.install(time=...)` |
| Java | `page.clock.install(time)` |

## Required pattern

All clock operations require `install()` first:

```ts
await page.clock.install({ time: '2024-01-01T00:00:00.000Z' })
await page.clock.setFixedTime('2020-01-01T00:00:00.000Z')
const ts = await page.evaluate<number>('Date.now()')
// ts === 1577836800000 ✓
```

**#125 — FIXED v26.5.31** (PR #163): `setFixedTime()` without prior `install()` silently had no effect in v26.3.18. v26.5.31 now returns an error message instead of silently succeeding. Standalone `setFixedTime()` (without install) is still not supported. → [[methods/cl-s-fixed]] · → [[bugs/js#125]]

→ [[reference/api-reference]]
