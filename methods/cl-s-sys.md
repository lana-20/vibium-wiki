---
method: cl-sSys
category: clock
last_tested: v26.5.31
bugs: [JV-137]
status: partial
---

# cl-sSys / clock.setSystemTime

Override the system clock to a specific time without stopping timers.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `—` |
| MCP | `page_clock_set_system_time { time }` |
| JS | `page.clock.setSystemTime(time)` |
| Python | `page.clock.set_system_time(time)` |
| Java | `page.clock.setSystemTime(time)` |

## Known issues

**JV-137 — partial (#137):** `ClockOptions.time()` builder path ignored in Java. Pass time directly as a string arg instead.

**Workaround:** `clock.setSystemTime("2024-01-01T00:00:00.000Z")` works; `new ClockOptions().time(...)` does not.

→ [[bugs/java#137]] · → [[methods/cl-inst]] · → [[reference/api-reference]]
