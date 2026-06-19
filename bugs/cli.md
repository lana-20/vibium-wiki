# CLI Bug Index — B1–B33

Last run: v26.5.31 · 2026-06-01  
Original report: VibiumDev/vibium#112

| ID | Severity | Priority | Method(s) | Status (v26.5.31) | Workaround |
|---|---|---|---|---|---|
| B1 | Critical | P1 | count | fixed v26.5.31 | eval workaround (no longer needed) |
| B2 | Critical | P1 | storage | fixed v26.5.31 | — |
| B3 | Critical | P1 | dialog, click | open (#112) | pre-stub `window.alert/confirm`; fire-and-forget eval navigation |
| B4 | High | P1 | cookies | fixed v26.5.31 | — |
| B5 | High | P1 | select | partial v26.5.31 (#140) | label matching fixed; error on non-match fixed |
| B6 | High | P1 | click | open (#112) | use shell `timeout` wrapper |
| B7 | High | P1 | fill | fixed v26.5.31 (#117) | click+type workaround (no longer needed for textarea) |
| B8 | High | P2 | attr | open | eval `.hasAttribute()` |
| B9 | High | P2 | eval | fixed | JSON.stringify workaround (no longer needed) |
| B10 | Medium | P2 | is | open | requires 2 args — pass element ref explicitly |
| B11 | Medium | P2 | back | open | check URL before calling back |
| B12 | Medium | P2 | completion | open | source zsh completion manually |
| B13 | Medium | P2 | daemon | open | check daemon PID file instead |
| B14 | Medium | P2 | geolocation | open | wrap negative coord in `-- ` arg separator |
| B15 | Medium | P2 | find | regression-check | search by DOM text not rendered text |
| B16 | Medium | P2 | map | open | eval shadowRoot traversal (but also returns null on Polymer Shop) |
| B17 | Medium | P2 | find | open | eval `.click()` on input[type=submit] |
| B18 | Medium | P2 | fill, type | open | eval native value setter + dispatchEvent |
| B19 | Medium | P2 | frame | open | eval `.contentDocument` cross-frame access |
| B20 | Medium | P2 | fill | open | eval to clear field; type accepts `""` but silently no-ops |
| B21 | High | P3 | bidi-test, launch-test | open | — |
| B22 | Medium | P3 | sleep | open | validate before calling |
| B23 | Medium | P3 | sleep | open | validate before calling |
| B24 | Medium | P3 | map | open | eval getBoundingClientRect + mouse click |
| B25 | Medium | P3 | text | open | eval with slice to avoid buffer limit |
| B26 | Low | P3 | check | open | verify element type with eval before calling |
| B27 | Low | P3 | ws-test | open | manually use wss:// scheme |
| B28 | Low | P3 | upload | open | pass correct file input selector |
| B29 | Low | P3 | find | open | use map instead of find for interactable-only discovery |
| B30 | Low | P3 | hover | partial | mouse move workaround for img; div hover now works |
| B31 | Low | P3 | fill | open | eval value setter + dispatchEvent for range inputs |
| B32 | Low | P4 | serve | partial | teardown clean; port conflict hint still missing |
| B33 | Low | P4 | content | open | — |

## Detail entries

### B3 — dialog deadlock (Critical · P1 · open)

**Trigger:** `vibium click` on any element that fires a native JS dialog (`alert`, `confirm`, `prompt`) deadlocks the daemon socket — the click command blocks until i/o timeout. `vibium dialog accept` issued after also hangs.

**Sites confirmed:** the-internet.herokuapp.com/javascript_alerts, eviltester.com/alerts, phptravels.com, demo.prestashop.com

**Extended variant — form POST navigation:** same deadlock triggered by form submissions that cause page navigation. Pre-stubbing dialogs does not prevent this.

**Extended variant — PrestaShop subdomain navigation:** `vibium go` to a PrestaShop subdomain page also deadlocks. `vibium click` on nav links within the subdomain also deadlocks.

**Workaround (dialogs):** pre-stub before clicking — `vibium eval 'window.alert = () => {}; window.confirm = () => true; window.prompt = () => "text"'`

**Workaround (navigation):** use eval to navigate — `vibium eval "location.href = '...'"` then `vibium wait load` instead of `vibium go` to subdomain pages.

**Recovery:** `pkill -f vibium && sleep 2 && vibium daemon start && sleep 2`

→ [[methods/dialog]] · → [[methods/click]] · → [[patterns/dialog_deadlock]]

---

### B5 — select silent false success (High · P1 · partial)

**v26.5.31 fix:** select by visible label now works (previously matched `value` attribute only).

**Remaining:** selecting a nonexistent option returns exit 0 with success message but the selected value is empty. Should be exit 1 with option-not-found error.

→ [[methods/select]]

---

### B15 — find text case sensitivity (Medium · P2 · regression-check)

**Status:** confirmed correct behavior as of v26.5.31. `find text` is case-sensitive against DOM text only; CSS `text-transform` never applied. Retained as regression check.

**Rule:** search by DOM text, not rendered text. On sites with `text-transform: uppercase`, the DOM text is mixed-case — search for that.

→ [[methods/find]] · → [[patterns/find_text_case]]

---

### B30 — hover partial fix (Low · P3 · partial)

**v26.5.31 fix:** `hover` on `<div>` with explicit size now works (exit 0).

**Remaining:** `hover` on `<img src="https://...">` fails with `visible check failed — zero size` — image not yet sized at hover time (race condition with external image load).

**Workaround for img:** `vibium mouse move x y` with coordinates from `getBoundingClientRect()`.

→ [[methods/hover]]

---

## Related: closed issues outside the B1–B33 block

### #173 — `vibium click` — "element is obscured" on var.parts after add-to-cart (closed)

[VibiumDev/vibium#173](https://github.com/VibiumDev/vibium/issues/173) — `vibium click` reports `receivesEvents check failed — element is obscured` on var.parts product pages after adding an item to cart. Closed (completed) by @hugs.

**Note:** This is CLI-only and site-specific to var.parts. Not part of the original B1–B33 block; tracked here for cross-reference only.
