---
method: fill
aliases: [browser_fill]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B7, B18, B20, B31, MCP-155]
status: partial
---

# fill / browser_fill

Sets the value of an input element. Clears existing value then types the new value.

## Supported element types

| Type | CLI status | MCP status |
|---|---|---|
| `input[type=text]` | ok | ok |
| `input[type=password]` | ok | ok |
| `input[type=email]` | ok | ok |
| `input[type=number]` | ok | ok |
| `textarea` | fixed v26.5.31 (was B7) | fixed v26.5.31 (was MCP #155) |
| `input[type=range]` | open — B31 | untested |
| empty string value `""` | open — B20 | untested |
| negative number value `"-2"` | open — B18 | untested |

## Known bugs

### B7 / MCP #155 — fill fails on `<textarea>` · fixed v26.5.31

Previously: `element type is not supported for fill` on textarea elements.

Now fixed in both CLI and MCP. Both correctly fill textareas.

Workaround (historical, no longer needed): `vibium click "textarea" && vibium type "textarea" "text"` — note this appended rather than replaced.

---

### B18 — negative values parsed as flags · open

**CLI only.** Any value starting with `-` is parsed as a flag argument.

```sh
vibium fill "input#first" "-2"
# Error: unknown shorthand flag: '2' in -2
```

**Workaround:** eval native value setter:
```sh
vibium eval 'const s=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,"value").set; const el=document.querySelector("input#first"); s.call(el,"-2"); el.dispatchEvent(new Event("input",{bubbles:true})); el.value'
```

Same root cause as B14 (geolocation), B22 (sleep). → [[patterns/negative_values]]

---

### B20 — fill rejects empty string · open

**CLI only.** `vibium fill "#sel" ""` → `Error: value is required` — CLI rejects `""` before reaching the browser.

**type inconsistency:** `vibium type "#sel" ""` accepts empty string (exit 0) but silently no-ops — field value unchanged.

**Workaround:** `vibium eval 'document.querySelector("#sel").value = ""'`

**Whitespace note:** `" "` (space) is accepted (exit 0) but leaves literal whitespace, not an empty field.

---

### B31 — fill fails on `input[type=range]` · open

Same class as B7 (textarea) — fill rejects range inputs as "not editable".

```sh
vibium fill "#slider" "3"
# failed to fill: ... editable check failed — input type range not editable
```

**Workaround:**
```sh
vibium eval 'const s=document.querySelector("input[type=range]"); s.value="3"; s.dispatchEvent(new Event("input",{bubbles:true})); s.dispatchEvent(new Event("change",{bubbles:true})); s.value'
```

## Related

→ [[bugs/cli#B7]] · → [[bugs/cli#B18]] · → [[bugs/cli#B20]] · → [[bugs/cli#B31]] · → [[bugs/mcp#155]]
