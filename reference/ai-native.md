# AI-Native Methods

Source: `docs/specs/ai-native-methods.md`

> **Status: Draft / Not yet implemented.** Proposed API, not yet in any released version.

Vibium's planned signature differentiators — no Playwright or Selenium equivalent.

---

## `page.check(claim, options?)` — AI-Powered Verification

Plain English assertions backed by a screenshot + multimodal LLM call.

```javascript
await vibe.check('the shopping cart icon shows 0 items')
await vibe.check('user is logged in')
await vibe.check('prices are sorted low to high')
await vibe.check('the form shows a validation error for email')

// With selector hint to narrow scope
await vibe.check('shows 3 results', { near: '.search-results' })

// Structured result
const result = await vibe.check('the dashboard loaded successfully')
// { passed: true, reason: "...", screenshot: Buffer, confidence: 0.95 }

const { passed } = await vibe.check('no error messages visible')
assert(passed)
```

**Implementation:** screenshot → multimodal LLM → structured response. Optionally augmented with DOM snapshot / a11y tree.

**Options:**
- `near` — CSS selector to constrain visual/DOM region
- `timeout` — max wait time (default: 5s, retries until claim passes)
- `screenshot` — include screenshot in result (default: true)
- `model` — override default AI model

---

## `page.do(action, options?)` — AI-Powered Action

Natural language actions when you don't know exact selectors.

```javascript
await vibe.do('log in with username "admin" and password "secret"')
await vibe.do('add the first item to cart')
await vibe.do('close the cookie consent banner')

// With constraints
await vibe.do('fill out the shipping form', {
  data: { name: 'Jane Doe', address: '123 Main St', zip: '60601' }
})

// Structured result
const result = await vibe.do('click the submit button')
// { done: true, steps: ['Found submit button...', 'Clicked button'], screenshot: Buffer }
```

**Implementation:** screenshot + DOM snapshot → LLM plans actions → executes via Vibium's deterministic API (`find`, `click`, `fill`, etc.) → verifies result.

**Key insight:** `page.do()` uses Vibium's own deterministic API under the hood — AI planning, not AI puppeteering. The actions it takes are the same `find()`, `click()`, `fill()` commands a human would write.

---

## Philosophy

| Style | Code |
|---|---|
| Deterministic (current) | `await vibe.find('testid=cart-count').text() // "0"` |
| AI-powered (planned) | `await vibe.check('cart is empty')` |

The two styles coexist — `page.check()` doesn't replace `el.text()`, it complements it.

→ [[reference/roadmap]]
