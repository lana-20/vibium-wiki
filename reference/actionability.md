# Actionability — How Vibium Waits for Elements

Source: `clicker/internal/api/actionability.go` · `docs/explanation/actionability.md`

Vibium runs actionability checks **server-side in Go** before every interaction. This means client libraries (JS, Python, Java) don't need retry logic — they send a command and wait for success or timeout.

---

## The five checks

| Check | Condition | Implemented in |
|---|---|---|
| **Visible** | Non-zero bounding box; not `display:none`; not `visibility:hidden` | JS (in-page script) |
| **Stable** | Bounding box unchanged over 50ms | Go (two-pass comparison) |
| **ReceivesEvents** | `elementFromPoint(cx, cy)` returns the element or a descendant | JS (in-page script) |
| **Enabled** | Not `disabled`, not `aria-disabled="true"`, not inside `<fieldset disabled>` | JS (in-page script) |
| **Editable** | Is a text-accepting input (`<input>`, `<textarea>`, `contenteditable`); not `readOnly` or `aria-readonly` | JS (in-page script) |

---

## Which checks run per action

```go
// From actionability.go
ClickChecks  = []ActionCheck{CheckVisible, CheckStable, CheckReceivesEvents, CheckEnabled}
HoverChecks  = []ActionCheck{CheckVisible, CheckStable, CheckReceivesEvents}
FillChecks   = []ActionCheck{CheckVisible, CheckEnabled, CheckEditable}
SelectChecks = []ActionCheck{CheckVisible, CheckEnabled}
ScrollChecks = []ActionCheck{CheckStable}
```

| Action | Checks |
|---|---|
| click, dblclick, tap, check, uncheck, type, press | ClickChecks |
| hover, dragTo | HoverChecks |
| fill | FillChecks |
| selectOption | SelectChecks |
| scrollIntoView | ScrollChecks |

---

## Why bugs happen — source-level explanations

### B30 / hover on img with external src — zero size (Visible fails)

`HoverChecks` includes `CheckVisible`. The visibility check reads `rect.width === 0 || rect.height === 0`. External images haven't loaded and been laid out yet at hover time → `getBoundingClientRect()` returns zero size → `visible check failed — zero size`.

Div elements with explicit `width/height` CSS pass immediately (fixed in v26.5.31). External-src images race against the browser's image layout.

---

### B29 / find returns disabled element (Enabled inconsistency)

`vibium find` does NOT run actionability checks — it only resolves the selector. `vibium map` runs its own filter that excludes disabled elements. `vibium click` runs `ClickChecks` which includes `CheckEnabled`. This is why `find` leaks a `@ref` for a disabled element that `click` then rejects.

**Rule:** use `map` instead of `find` when you need to guarantee the element is actionable.

---

### B17 / find role button times out on input[type=submit] (role matching)

Semantic role matching uses explicit `role` attributes first, then maps HTML element types to ARIA roles. `input[type=submit]` has an implicit ARIA role of `button` per spec, but Vibium's semantic matching does not yet enumerate all implicit role mappings. So `find role button` scans for `<button>` elements and elements with explicit `role="button"` but misses `input[type=submit]`.

---

## The polling loop

```
deadline = now + timeout (default 30s)

loop:
    scroll element into view (scrollIntoViewIfNeeded || scrollIntoView)
    run JS actionability script (all JS checks in one BiDi round-trip)
    if check failed or not found:
        if past deadline: TimeoutError
        sleep 100ms; continue
    
    if stability check needed:
        sleep 50ms
        run JS script again
        if bboxes differ:
            if past deadline: TimeoutError
            sleep 100ms; continue
    
    return element info (tag, text, bounding box)
```

---

## Semantic selector reference

| Parameter | Matches |
|---|---|
| `role` | ARIA role (explicit or implicit from tag) |
| `text` | `textContent` (substring, case-sensitive) |
| `label` | `aria-label`, `aria-labelledby`, associated `<label>` |
| `placeholder` | `placeholder` attribute |
| `alt` | `alt` attribute |
| `title` | `title` attribute |
| `testid` | `data-testid` attribute |
| `xpath` | XPath expression |
| `selector` | CSS selector (can combine with above) |
| `index` | 0-based index when multiple match |
| `scope` | CSS selector restricting search to subtree |

**pickBest heuristic:** when `text` matches multiple elements, Vibium picks the one with the shortest `textContent`. This prefers `<button>Submit</button>` over a `<div>` containing "Submit" buried in a paragraph.

**CLI syntax:**
```sh
vibium find role button --name "Submit"
vibium find text "Add to Cart"
vibium find "#sel"
```

**JS/Python syntax:**
```js
page.find({ role: 'button', text: 'Submit' })
page.find({ label: 'Email' })
page.find({ selector: 'nav', role: 'link', text: 'Home' })
```

---

## Source files

| File | Contents |
|---|---|
| `clicker/internal/api/actionability.go` | Check definitions, `buildActionableScript`, `actionabilityCheckBody`, `WaitForActionable`, `resolveWithActionability` |
| `clicker/internal/api/handlers_interaction.go` | `Click`, `Hover`, `Fill`, `TypeInto`, `SelectOption`, `DragTo`, etc. |
| `clicker/internal/api/handlers_elements.go` | `buildFindScript`, `semanticMatchesHelper`, `pickBest` |
| `clicker/internal/api/router.go` | `DefaultTimeout` (30s) |

→ [[methods/hover]] · → [[methods/find]] · → [[methods/click]] · → [[methods/fill]] · → [[bugs/cli#B17]] · → [[bugs/cli#B29]] · → [[bugs/cli#B30]]
