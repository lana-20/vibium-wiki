---
method: dlg-dis
aliases: [browser_dialog_dismiss]
last_tested: v26.5.31
bugs: [B3]
status: open
---

# dlg-dis / dialog dismiss

Dismiss a pending native browser dialog (confirm, prompt). Equivalent to clicking Cancel.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium dialog dismiss` |
| MCP | `browser_dialog_dismiss {}` |
| JS | `page.capture.dialog(fn)` (dismiss path) |
| Python | `page.capture.dialog(fn)` |
| Java | `page.captureDialog(fn)` |

Subject to the same click→dialog deadlock as accept. See → [[methods/dlg-acc]] for workarounds.

→ [[patterns/dialog_deadlock]] · → [[bugs/cli#B3]] · → [[reference/api-reference]]
