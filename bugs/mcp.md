# MCP Bug Index

Last run: v26.5.31 · 2026-06-06

| gh Issue | Severity | Priority | Tool(s) | Status (v26.5.31) | Workaround |
|---|---|---|---|---|---|
| [#149](https://github.com/VibiumDev/vibium/issues/149) | Critical | P1 | browser_count | fixed | browser_evaluate `.length.toString()` (no longer needed) |
| [#150](https://github.com/VibiumDev/vibium/issues/150) | Critical | P1 | browser_storage_state | fixed | — |
| [#151](https://github.com/VibiumDev/vibium/issues/151) | Critical | P1 | browser_dialog_accept, browser_click | open · deferred | setTimeout before click; never await click inside dialog handler |
| [#152](https://github.com/VibiumDev/vibium/issues/152) | High | P1 | browser_set_cookie | fixed | — |
| [#153](https://github.com/VibiumDev/vibium/issues/153) | High | P2 | browser_get_attribute | fixed | browser_evaluate `.hasAttribute()` (no longer needed) |
| [#154](https://github.com/VibiumDev/vibium/issues/154) | High | P2 | browser_evaluate | fixed | JSON.stringify wrap (no longer needed) |
| [#155](https://github.com/VibiumDev/vibium/issues/155) | High | P2 | browser_fill | fixed | browser_click + browser_type (no longer needed) |
| [#156](https://github.com/VibiumDev/vibium/issues/156) | Medium | P3 | browser_screenshot | fixed | annotate: false then manual annotation (no longer needed) |
| [#157](https://github.com/VibiumDev/vibium/issues/157) | Medium | P3 | browser_get_text | fixed | browser_evaluate with `\|\| null` (no longer needed) |

## Detail entries

### #151 — dialog deadlock (Critical · P1 · open · [#151](https://github.com/VibiumDev/vibium/issues/151))

**Trigger:** `browser_click` on an element that fires a native dialog blocks indefinitely — the BiDi socket does not return until the dialog is dismissed, but `browser_dialog_accept` cannot run while the socket is blocked.

**Sites confirmed:** the-internet.herokuapp.com, eviltester.com/alerts, testautomationpractice.blogspot.com, testtrack.org/alert-demo

**Workaround:** use `browser_evaluate { expression: "setTimeout(() => alert('msg'), 300)" }` then `browser_dialog_accept {}` — the setTimeout fires after the evaluate returns, so the socket is free.

**Pre-stub workaround:** `browser_evaluate { expression: "window.alert = () => {}" }` before clicking — dialog fires but is intercepted by JS, never reaches BiDi layer.

**Recovery:** `browser_stop {}` then `browser_start {}` (allow ~30s before force-quitting).

→ [[methods/dialog]] · → [[methods/click]] · → [[patterns/dialog_deadlock]]

