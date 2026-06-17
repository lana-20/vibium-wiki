---
method: dialog
aliases: [browser_dialog_accept, browser_dialog_dismiss]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B3]
status: open
---

# dialog / browser_dialog_accept / browser_dialog_dismiss

Accepts or dismisses a pending native browser dialog (alert, confirm, prompt).

## Critical behavior — deadlock with click (B3 / MB3)

**This is the most dangerous bug in Vibium.** Clicking an element that fires a native dialog (`alert`, `confirm`, `prompt`) deadlocks the daemon/session socket. The click command blocks until i/o timeout. `dialog accept` issued afterward also hangs.

**Status:** open in both CLI (B3) and MCP (MB3, deferred #151) as of v26.5.31.

### Deadlock variants

| Trigger | Affected |
|---|---|
| `vibium click` on alert-firing element | CLI |
| `browser_click` on alert-firing element | MCP |
| Form POST that navigates away | CLI (same socket issue) |
| `vibium go` to PrestaShop subdomain page | CLI (same socket issue) |

### Safe workaround — pre-stub before click

```sh
# CLI
vibium eval 'window.alert = () => {}; window.confirm = () => true; window.prompt = () => "text"'
vibium click "@e1"   # now safe — dialog fires but is intercepted by JS

# MCP
browser_evaluate { expression: "window.alert = () => {}; window.confirm = () => true" }
browser_click { selector: "@e1" }
```

The click returns immediately. Pre-stub return values are observed by the page JS.

### Safe workaround — setTimeout approach (MCP)

```
browser_evaluate { expression: "setTimeout(() => alert('msg'), 300)" }
browser_dialog_accept {}
```

The evaluate returns before the setTimeout fires, so the socket is free when the dialog appears.

### Safe workaround — navigation deadlock

For PrestaShop and form-POST navigation:
```sh
vibium eval "location.href = 'https://target-url/path'"
vibium wait load --timeout 10000
```

Do NOT use `vibium go` to a subdomain page that triggers navigation events.

### Recovery after deadlock

```sh
# CLI
pkill -f vibium && sleep 2 && vibium daemon start && sleep 2

# MCP
browser_stop {}
browser_start {}
# allow ~30s before force-quitting
```

## capture.dialog pattern (JS API)

In the JS/Python/Java API `capture.dialog()` callback: the fn passed to `capture.dialog` must NOT await the click call. The capture handler resolves its promise but does not dismiss the dialog — awaiting the click creates a deadlock.

**Correct pattern:**
```ts
await page.capture.dialog(async () => {
  page.find({ role: 'button', text: 'Alert' }).click().catch(() => {})  // fire-and-forget
})
```

→ [[patterns/dialog_deadlock]] · → [[methods/click]] · → [[bugs/cli#B3]] · → [[bugs/mcp#MB3]]
