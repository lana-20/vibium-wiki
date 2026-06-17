# Pattern: find text Case Sensitivity

## Summary

`vibium find text "..."` (CLI) and `browser_find { text: "..." }` (MCP) match against raw DOM text only. CSS `text-transform` is never applied. Matching is case-sensitive.

**Status:** confirmed correct, consistent behavior in v26.5.31. Classified as regression-check (B15), not an active bug.

---

## Rules

1. Search string must match DOM text exactly — case-sensitive
2. CSS `text-transform: uppercase` does NOT affect matching — search by DOM text, not rendered text
3. `find text` returns the outermost element containing the text — not necessarily the interactive child

---

## Examples

```sh
# DOM text: "add to cart" — rendered "ADD TO CART" via CSS
vibium find text "ADD TO CART"   # exit 1 — not found (correct)
vibium find text "add to cart"   # exit 0 — found (correct)

# DOM text: "Add to Cart" — rendered "ADD TO CART" via CSS  
vibium find text "ADD TO CART"   # exit 1 — not found (correct)
vibium find text "Add to Cart"   # exit 0 — found (correct)
```

---

## Sites where this matters

| Site | DOM text | Visual rendering | Correct search term |
|---|---|---|---|
| academybugs.com nav | "Shop", "Find Bugs" | "SHOP", "FIND BUGS" | DOM-cased |
| qa-practice.razvanvancea.ro | "ADD TO CART" (all caps in DOM) | "ADD TO CART" | "ADD TO CART" |

Note: the QA Practice site is unusual — DOM text is already uppercase, so CSS transform is irrelevant there.

---

## Discovery

Original symptom: searching by uppercase rendered text returned no results on AcademyBugs during practice-testing batch 3 (2026-04-22). Earlier suspected B15 was an inconsistency; isolated rerun in v26.5.31 confirmed it's consistent and correct behavior.

---

## Rule for automation

When automating a site with `text-transform: uppercase`, inspect the actual DOM text:
```sh
vibium eval 'document.querySelector(".nav-item").textContent'
```

Use `vibium map` refs instead of `find text` when display text differs from DOM text — refs are stable and don't depend on text matching.

→ [[methods/find]] · → [[bugs/cli#B15]]
