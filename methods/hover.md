---
method: hover
aliases: [browser_hover]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B30]
status: partial
---

# hover / browser_hover

Moves the mouse to the center of an element, triggering CSS `:hover` effects.

## v26.5.31 partial fix

| Element type | Status |
|---|---|
| `<div>` with explicit width/height | fixed — exit 0 |
| `<img src="https://...">` (external src) | open — `visible check failed — zero size` |
| Interactive elements (`<button>`, `<a>`) | ok (always worked) |

### Why img still fails (B30 · open)

The `visible` check runs before the browser has loaded and sized the external image. The element reports zero bounding box at hover time. This is a race condition — no timing workaround exists within `hover` itself.

**Workaround for img elements:**

```sh
# Get center coords while image is loaded
vibium eval 'JSON.stringify(document.querySelector("#img").getBoundingClientRect())'
# Extract x, y from output — e.g. left=100, top=200, width=200, height=150
# Center = (100 + 100, 200 + 75) = (200, 275)
vibium mouse move 200 275
vibium sleep 300  # allow CSS :hover to apply
```

## Live site verification

```sh
# Div hover (fixed)
vibium content '<div id="hov" style="width:100px;height:100px;background:blue;"></div>'
vibium hover "#hov"   # exit 0 (fixed)

# Img hover (still broken)
vibium content '<img id="img" src="https://placekitten.com/100/100" style="display:block">'
vibium hover "#img"   # exit 1 — zero size

# The Internet /hovers — .figure elements are divs, now work
vibium go http://the-internet.herokuapp.com/hovers && vibium wait load
vibium hover ".figure:first-child"   # exit 0 (fixed in v26.5.31)
```

## Related

→ [[bugs/cli#B30]]
