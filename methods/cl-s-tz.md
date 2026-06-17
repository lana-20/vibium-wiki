---
method: cl-sTZ
category: clock
last_tested: v26.5.31
bugs: []
status: stub
---

# cl-sTZ / clock.setTimezone

Override the browser timezone for date/time display and Intl APIs.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `—` |
| MCP | `page_clock_set_timezone { timezone }` |
| JS | `page.clock.setTimezone(timezone)` |
| Python | `page.clock.set_timezone(timezone)` |
| Java | `page.clock.setTimezone(timezone)` |

```ts
await page.clock.install()
await page.clock.setTimezone('America/New_York')
```

→ [[methods/cl-inst]] · → [[reference/api-reference]]
