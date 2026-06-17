# MCP Bug Index — MB1–MB10

Last run: v26.5.31 · 2026-06-06

| ID | gh Issue | Severity | Priority | Tool(s) | Status (v26.5.31) | Workaround |
|---|---|---|---|---|---|---|
| MB1 | [#149](https://github.com/VibiumDev/vibium/issues/149) | Critical | P1 | browser_count | fixed | browser_evaluate `.length.toString()` (no longer needed) |
| MB2 | [#150](https://github.com/VibiumDev/vibium/issues/150) | Critical | P1 | browser_storage_state | fixed | — |
| MB3 | [#151](https://github.com/VibiumDev/vibium/issues/151) | Critical | P1 | browser_dialog_accept, browser_click | open · deferred | setTimeout before click; never await click inside dialog handler |
| MB4 | [#152](https://github.com/VibiumDev/vibium/issues/152) | High | P1 | browser_set_cookie | fixed | — |
| MB5 | [#153](https://github.com/VibiumDev/vibium/issues/153) | High | P2 | browser_get_attribute | fixed | browser_evaluate `.hasAttribute()` (no longer needed) |
| MB6 | [#154](https://github.com/VibiumDev/vibium/issues/154) | High | P2 | browser_evaluate | fixed | JSON.stringify wrap (no longer needed) |
| MB7 | [#155](https://github.com/VibiumDev/vibium/issues/155) | High | P2 | browser_fill | fixed | browser_click + browser_type (no longer needed) |
| MB8 | [#156](https://github.com/VibiumDev/vibium/issues/156) | Medium | P3 | browser_screenshot | fixed | annotate: false then manual annotation (no longer needed) |
| MB9 | [#157](https://github.com/VibiumDev/vibium/issues/157) | Medium | P3 | browser_get_text | fixed | browser_evaluate with `\|\| null` (no longer needed) |
| MB10 | — | High | P2 | browser_click | intermittent · open · not reported | browser_evaluate `.click()` or mouse_click by coords |

## Detail entries

### MB3 / #151 — dialog deadlock (Critical · P1 · open · [#151](https://github.com/VibiumDev/vibium/issues/151))

**Trigger:** `browser_click` on an element that fires a native dialog blocks indefinitely — the BiDi socket does not return until the dialog is dismissed, but `browser_dialog_accept` cannot run while the socket is blocked.

**Sites confirmed:** the-internet.herokuapp.com, eviltester.com/alerts, testautomationpractice.blogspot.com, testtrack.org/alert-demo

**Workaround:** use `browser_evaluate { expression: "setTimeout(() => alert('msg'), 300)" }` then `browser_dialog_accept {}` — the setTimeout fires after the evaluate returns, so the socket is free.

**Pre-stub workaround:** `browser_evaluate { expression: "window.alert = () => {}" }` before clicking — dialog fires but is intercepted by JS, never reaches BiDi layer.

**Recovery:** `browser_stop {}` then `browser_start {}` (allow ~30s before force-quitting).

→ [[methods/dialog]] · → [[methods/click]] · → [[patterns/dialog_deadlock]]

---

### MB10 — false "element obscured" on sticky nav (High · P2 · intermittent · not reported)

**Note on #173:** [VibiumDev/vibium#173](https://github.com/VibiumDev/vibium/issues/173) "vibium click fails with 'element is obscured' on var.parts" (closed) is a related CLI bug on a different site — not the same as MB10. CLI `vibium click` is unaffected by MB10; #173 is tracked separately in bugs/cli.md.

**Trigger:** `browser_click` reports `receivesEvents check failed — element is obscured` on elements that are not obscured. Requires all three CSS properties simultaneously on a nav: `position:sticky` + explicit `z-index` + `backdrop-filter`.

**Repro site:** automation-exercise.daisyladybug.com (Next.js/React app with sticky nav using `position:sticky + z-index:50 + backdrop-filter:blur(12px)`). Does not reproduce on synthetic `set_content` pages.

**Hypothesis:** hydration-timing dependent — manifests during React hydration window. Does not reproduce every session.

**CLI comparison:** `vibium click` (CLI) is unaffected — bug is MCP-specific.

**Workaround A:** `browser_evaluate { expression: "document.querySelector('...').click()" }`
**Workaround B:** get coords via getBoundingClientRect → `browser_mouse_click { x, y }`

→ [[methods/click]]
