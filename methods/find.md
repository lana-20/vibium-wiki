---
method: find
aliases: [browser_find]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B15, B17, B29]
status: partial
---

# find / browser_find

Locates an element on the page and returns a `@ref`. Three selector modes:

- CSS selector: `vibium find "#id"` / `vibium find "button.primary"`
- Text: `vibium find text "Add to Cart"`
- Role + text: `vibium find role button --name "Login"`

## Behavioral notes

### Text matching is case-sensitive against DOM text · B15 (regression-check)

`find text` matches raw DOM text only — CSS `text-transform` is never applied.

```sh
# Button with DOM text "add to cart" rendered uppercase via CSS
vibium find text "ADD TO CART"   # exit 1 — not found (correct)
vibium find text "add to cart"   # exit 0 — found (correct)
```

**Rule:** search by DOM text, not rendered text. On sites with `text-transform: uppercase`, inspect the DOM (e.g. via `vibium eval`) to get the actual text.

Confirmed consistent behavior in v26.5.31. Classified as regression-check, not a bug.

→ [[patterns/find_text_case]]

---

### find { text } returns outermost containing element, not the interactive child

`find text "..."` returns the outermost element containing the matching text. On pages with structure like `<li><button>Text</button></li>`, `find text "Text"` returns the `<li>` wrapper. Actionability check on `<li>` then times out or fails.

**Rule:** always use `find role button --name "..."` or `find role link --name "..."` when you need a specific interactive element. Plain `find text` is only safe when the text is directly on the interactive element.

Discovered on the-internet.herokuapp.com/javascript_alerts (dialog tests).

---

### B17 — find role button times out on input[type=submit] · open

Per ARIA spec, `input[type=submit]` has implicit role `button`. `vibium find role button --name "Login"` does not recognise this — it times out after 30s.

```sh
vibium content '<input type="submit" value="Login">'
vibium find role button --name "Login"
# times out — exit 1 (124 with shell timeout)
```

**Workaround:** `vibium eval 'document.querySelector("input[type=submit]").click()'`

Live site: practicesoftwaretesting.com login form uses `input[type=submit]`.

---

### B29 — find returns @ref for disabled elements · open

CSS selector mode (`find "#sel"`) returns an `@ref` for disabled elements. This is inconsistent with `map` which correctly excludes disabled elements.

```sh
vibium eval 'document.body.insertAdjacentHTML("beforeend","<button id=\"b\" disabled>X</button>")'
vibium find "#b"         # exit 0 — returns @e1 (BUG: should be exit 1)
vibium map --selector "#b"  # "No interactive elements found" (correct)
vibium click @e1         # exit 1 — "enabled check failed — disabled attribute"
```

**Rule:** use `vibium map` rather than `vibium find` when you need to guarantee the element is actionable.

Note: `find text` and `find role` also leak for `<button>` but not for `<input>` types.

---

### JS #118 — No pierce selector for shadow DOM · open (enhancement) {#shadow-dom}

`page.find()` and `page.findAll()` do not cross shadow boundaries. There is no pierce combinator (`>>` or `>>>`). Standard CSS selectors are also blocked — `document.querySelector('host p')` returns null across a shadow root.

```ts
// Current: must use evaluate() + manual shadowRoot traversal
const text = await page.evaluate<string>(
  `document.querySelector('my-paragraph').shadowRoot.querySelector('p').textContent.trim()`
)

// Proposed (not yet implemented):
const p = await page.find('my-paragraph >> p')
const items = await page.findAll('my-paragraph >> p')
```

**Workaround:** `page.evaluate()` with `element.shadowRoot.querySelector(...)`.

**Repro file:** `tests/repro-enhancement-shadow-pierce.test.ts` (vibium-js-test repo)

→ [[bugs/js#118]]

## Related

→ [[methods/map]] · → [[bugs/cli#B15]] · → [[bugs/cli#B17]] · → [[bugs/cli#B29]] · → [[bugs/js#118]]
