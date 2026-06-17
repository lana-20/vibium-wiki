---
method: click
aliases: [browser_click]
last_tested: v26.5.31
last_tested_date: 2026-06-06
bugs: [B3, B6, MCP-151]
status: open
---

# click / browser_click

Clicks an element identified by a CSS selector or `@ref`.

## Known bugs

### B3 — deadlock on dialog-firing elements · open

Clicking any element that fires a native JS dialog deadlocks the daemon socket. See → [[methods/dialog]] for full detail, workarounds, and recovery.

---

### B6 — --timeout flag silently ignored · open (CLI only)

```sh
vibium click "#delayed-btn" --timeout 3s
# fails in ~160ms with "timeout after 0s" — flag ignored
```

The timeout flag is accepted at CLI parse time but not forwarded to the underlying wait-for-element logic. Default timeout (~160ms) is always used.

**Workaround:** use shell `timeout` wrapper:
```sh
timeout 10 vibium click "#delayed-btn"
```

Or inject a polling loop via eval before clicking.

---

### MB10 — false "element obscured" on sticky nav pages · intermittent (MCP only)

`browser_click` reports `receivesEvents check failed — element is obscured` on elements that are demonstrably not obscured. Requires all three CSS properties simultaneously on a nav element: `position:sticky` + explicit `z-index` + `backdrop-filter`.

**CLI comparison:** `vibium click` is unaffected — MCP-specific.

**Trigger:** confirmed on automation-exercise.daisyladybug.com (Next.js/React, sticky nav with `position:sticky + z-index:50 + backdrop-filter:blur(12px)`). Does not reproduce on synthetic pages or every session (hydration-timing hypothesis).

**Workaround A:** `browser_evaluate { expression: "document.querySelector('...').click()" }`

**Workaround B:** get coords via `getBoundingClientRect` → `browser_mouse_click { x, y }`

→ [[bugs/mcp#MB10]]

## Related

→ [[methods/dialog]] · → [[bugs/cli#B3]] · → [[bugs/cli#B6]] · → [[bugs/mcp#MB10]]
