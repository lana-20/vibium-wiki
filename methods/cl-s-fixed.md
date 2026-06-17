---
method: cl-sFixed
aliases: [page_clock_set_fixed_time, page.clock.setFixedTime]
last_tested: v26.5.31
bugs: [Bug3]
status: partial
---

# cl-sFixed / clock.setFixedTime

Set Date.now() to a fixed value. Requires prior `clock.install()`.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium clock set-fixed-time "<ISO8601>"` |
| MCP | `page_clock_set_fixed_time { time }` |
| JS | `page.clock.setFixedTime(time)` |
| Python | `page.clock.set_fixed_time(time)` |
| Java | `page.clock.setFixedTime(time)` |

## Known issues

**Bug 3 — FIXED v26.5.31**: calling `setFixedTime()` without prior `clock.install()` silently had no effect in v26.3.18. v26.5.31 returns an error. Standalone `setFixedTime()` (without install) remains unsupported. → [[methods/cl-inst]] · → [[bugs/js#Bug3]]

→ [[reference/api-reference]]
