---
method: eval / evaluate
aliases: [browser_evaluate, page.eval, page.evaluate]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B9]
status: partial
---

# eval / evaluate / browser_evaluate

Executes JavaScript in the page context and returns the result.

## Fixed in v26.5.31

| Bug | Description |
|---|---|
| B9 (CLI) | Objects/arrays printed as Go internal repr (`map[type:string value:...]`) — now returns valid JSON |
| MB6 (MCP) | Empty string `""` result caused `invalid_union` serialization error — fixed (#154) |
| #123, #131, #145 | `waitUntil` / `waitForFunction` accepted only arrow functions — bare expressions now work |

## Open issues

### #124 — page.evaluate() wraps nested string[][] as BiDi typed objects (open)

When an expression returns a `string[][]` (nested array), the JS/Python/Java clients deserialize inner array items as BiDi typed objects `{ type: "string", value: "..." }` instead of plain JS strings. A flat `string[]` deserializes correctly — only the second (and deeper) nesting level is affected.

**Distinct from B9** — B9 was top-level object/array repr in CLI output. #124 is nested array deserialization in client libraries.

**JS repro:**
```ts
// Flat string[] — works
const modes = await page.evaluate<string[]>(
  `[...document.querySelectorAll('my-paragraph')].map(h => h.shadowRoot.mode)`
)
// modes[0] === "open" ✓

// Nested string[][] — broken
const items = await page.evaluate<string[][]>(
  `[...document.querySelectorAll('my-paragraph')].map(h => [...h.shadowRoot.children].map(c => c.tagName))`
)
// items[0][0] === { type: "string", value: "STYLE" }  ← BUG
```

**Workaround** — round-trip via JSON (works in all clients):
```ts
// JS
const json = await page.evaluate<string>(
  `JSON.stringify([...document.querySelectorAll('my-paragraph')].map(h => [...h.shadowRoot.children].map(c => c.tagName)))`
)
const items = JSON.parse(json) as string[][]
```

```sh
# CLI (also works — JSON.stringify output is a plain string, not a nested array)
vibium eval 'JSON.stringify([["a","b"],["c","d"]])'
# Returns: '[["a","b"],["c","d"]]' — parse as needed
```

**Repro:** `tests/repro-bug2-evaluate-nested-array.test.ts` (vibium-js-test repo)

---

## Return type handling (v26.5.31)

| JS result type | CLI | MCP | Python | Java |
|---|---|---|---|---|
| string | as-is | as-is | as-is | as-is |
| number | stringified | stringified | number | number |
| boolean | stringified | stringified | bool | bool |
| object/array | JSON ✓ (fixed B9) | JSON ✓ (fixed B9) | dict/list | Map |
| nested array strings | may wrap (#124) | may wrap (#124) | may wrap | may wrap |
| `null` | "null" | null | None | null |
| `undefined` | "" or "undefined" | varies | None | null |
| empty string `""` | `""` | `""` ✓ (fixed MB6) | `""` | `""` |

---

## `--stdin` heredoc pattern (CLI)

For complex multi-line JS, use stdin to avoid shell escaping:

```sh
vibium eval --stdin <<'EOF'
JSON.stringify([...document.querySelectorAll("a")].slice(0,3).map(a => ({
  text: a.textContent.trim(),
  href: a.href
})))
EOF
```

Confirmed working in v26.5.31. Used heavily in practice-testing and cart-patrol.

---

## eval as universal workaround

`eval` is the escape hatch for most Vibium CLI/MCP bugs. Standard patterns:

**Clear a field (B20 workaround):**
```sh
vibium eval 'document.querySelector("#sel").value = ""'
```

**Fill negative value (B18 workaround):**
```sh
vibium eval 'const s=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,"value").set; const el=document.querySelector("#sel"); s.call(el,"-2"); el.dispatchEvent(new Event("input",{bubbles:true}))'
```

**Click a dialog-firing element without deadlock:**
```sh
vibium eval 'window.alert = () => {}; window.confirm = () => true'
vibium click "@e1"
```

**Navigate without deadlock (PrestaShop variant):**
```sh
vibium eval "location.href = 'https://target/path'"
vibium wait load
```

**Fill range input (B31 workaround):**
```sh
vibium eval 'const s=document.querySelector("input[type=range]"); s.value="3"; s.dispatchEvent(new Event("input",{bubbles:true})); s.dispatchEvent(new Event("change",{bubbles:true}))'
```

## Related

→ [[bugs/cli#B9]] · → [[bugs/mcp#MB6]] · → [[methods/fill]] · → [[patterns/dialog_deadlock]]
