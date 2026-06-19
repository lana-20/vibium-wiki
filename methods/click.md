---
method: click
aliases: [browser_click]
last_tested: v26.5.31
last_tested_date: 2026-06-06
bugs: [B3, B6, MCP-151 (deferred #151)]
status: open
---

# click / browser_click

Clicks an element identified by a CSS selector or `@ref`.

## Known bugs

### B3 / #151 — deadlock on dialog-firing elements · open (deferred · [#151](https://github.com/VibiumDev/vibium/issues/151))

Clicking any element that fires a native JS dialog deadlocks the daemon socket. CLI tracks as B3; MCP tracks as [#151](https://github.com/VibiumDev/vibium/issues/151) (deferred). See → [[methods/dialog]] for full detail, workarounds, and recovery.

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

## Related

→ [[methods/dialog]] · → [[bugs/cli#B3]] · → [[bugs/cli#B6]] · → [[bugs/mcp#151]]
