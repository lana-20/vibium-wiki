---
method: cl-pAt
category: clock
last_tested: v26.5.31
bugs: [JV-137]
status: partial
---

# cl-pAt / clock.pauseAt

Run all timers until a specific point in time, then pause the clock.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium clock pause-at "<time>"` |
| MCP | `page_clock_pause_at { time }` |
| JS | `page.clock.pauseAt(time)` |
| Python | `page.clock.pause_at(time)` |
| Java | `page.clock.pauseAt(time)` |

## Known issues

**JV-137 — partial (#137):** `ClockOptions.time()` builder path ignored in Java. Pass time directly as a string arg instead.

**Workaround:** `clock.pauseAt("2024-01-01T00:00:00.000Z")` works; `new ClockOptions().time(...)` does not.

→ [[bugs/java#137]] · → [[methods/cl-inst]] · → [[reference/api-reference]]
