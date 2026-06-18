---
method: dlg-acc
aliases: [browser_dialog_accept, page.capture.dialog]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B3, MCP-151]
status: open
---

# dlg-acc / dialog accept

Accept a pending native browser dialog (alert, confirm, prompt).

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium dialog accept [text]` |
| MCP | `browser_dialog_accept { text? }` |
| JS | `page.capture.dialog(fn)` |
| Python | `page.capture.dialog(fn)` |
| Java | `page.captureDialog(fn)` |

## Critical — deadlock with click (B3 / #151)

Clicking an element that fires a native dialog deadlocks the daemon socket. `dialog accept` issued afterward also hangs. **Status: open in CLI (B3) and MCP (#151, deferred).**

**Safe workaround — pre-stub:**
```sh
vibium eval 'window.alert = () => {}; window.confirm = () => true; window.prompt = () => "text"'
vibium click "@e1"   # safe — dialog is intercepted by JS
```

**Safe workaround — JS fire-and-forget:**
```ts
await page.capture.dialog(async () => {
  page.find({ role: 'button', text: 'Alert' }).click().catch(() => {})  // must NOT await
})
```

**Recovery after deadlock:**
```sh
pkill -f vibium && sleep 2 && vibium daemon start && sleep 2
```

→ [[patterns/dialog_deadlock]] · → [[methods/dlg-dis]] · → [[bugs/cli#B3]] · → [[bugs/mcp#151]] · → [[reference/api-reference]]
