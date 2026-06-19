---
method: map
aliases: [browser_map]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B16, B24]
status: open
---

# map / browser_map

Lists all interactive elements on the current page as numbered `@ref` handles. The primary element discovery mechanism for stable automation.

## Advantages over find

- Always excludes disabled elements (consistent — unlike `vibium find` which leaks disabled refs, B29)
- Gives stable `@ref` handles that survive between commands
- Works without knowing selector or text in advance

## Known bugs

### B16 — Web Components / shadow DOM elements not exposed · open

`map` returns "No interactive elements found" on pages where all UI lives inside custom element shadow roots (e.g. Polymer Shop).

**Confirmed on:** shop.polymer-project.org

**Workaround:** eval shadowRoot traversal — BUT on Polymer Shop specifically, `shadowRoot` returns `null` via eval too (full failure, no recovery path).

```sh
# Attempt shadow DOM traversal via eval
vibium eval 'JSON.stringify(document.querySelector("shop-app")?.shadowRoot?.querySelector("shop-list")?.shadowRoot?.querySelectorAll("a")?.length)'
# Returns: "null" on shop.polymer-project.org (also fails)
```

**Enhancement tracking:** JS #118 requests pierce selector support (`>>>` / `pierce/`) for shadow DOM — would fix B16 if implemented.

---

### B24 — Custom-rendered and canvas elements not exposed · open

Clickable elements styled as `<li>`, `<div>`, `<span>` (not `<button>` or `<a>`) do not appear in `map` output. Canvas-based UIs also missing.

**Confirmed on:** blackboxpuzzles.workroomprds.com (interactive puzzle circles as CSS-styled `<li>` elements)

**Workaround:** coordinate-based clicking via `getBoundingClientRect` + `vibium mouse click x y`

```sh
vibium eval 'JSON.stringify([...document.querySelectorAll("li")].slice(0,3).map(li => { const r = li.getBoundingClientRect(); return {x: Math.round(r.x + r.width/2), y: Math.round(r.y + r.height/2)} }))'
# Extract x,y from output
vibium mouse click 100 200
```

**Alternative:** `vibium a11y-tree` may expose elements that `map` misses — but on Polymer Shop, a11y-tree also fails.

---

## map vs find consistency

| Scenario | map | find |
|---|---|---|
| Disabled element | excluded (correct) | returns @ref (B29 bug) |
| Shadow DOM element | excluded (B16) | excluded (consistent) |
| CSS-styled non-interactive element | excluded (B24) | returns @ref if CSS selector used |
| `input[type=submit]` | included (has implicit button role) | `find role button` times out (B17) |

## Related

→ [[methods/find]] · → [[bugs/cli#B16]] · → [[bugs/cli#B24]] · → [[bugs/cli#B29]]
