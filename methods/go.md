---
method: go
aliases: [vibium go, browser_navigate, page.go]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B3, JS-126]
status: open
---

# go

Navigates the current page to a URL.

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `vibium go <url>` |
| MCP | `browser_navigate { url }` |
| JS | `page.go(url)` |
| Python | `page.go(url)` |
| Java | `page.go(url)` |

## Known issues

### B3 variant — `vibium go` deadlocks on PrestaShop subdomain pages · open

`vibium go` to a PrestaShop subdomain URL (e.g. `https://demo.prestashop.com/1-1-hummingbird-printed-t-shirt.html`) deadlocks the daemon socket. Same as the click→dialog deadlock — the navigation event blocks the BiDi socket.

**Also triggers on:** `vibium click` on internal nav links within the subdomain.

**Workaround:**
```sh
vibium eval "location.href = 'https://demo.prestashop.com/1-1-hummingbird-printed-t-shirt.html'"
vibium wait load --timeout 10000
```

Do NOT use `vibium go` to subdomain pages. Do NOT click internal PrestaShop nav links.

→ [[patterns/dialog_deadlock]] · → [[bugs/cli#B3]]

---

### #126 — capture.navigation() and page.url() miss SPA pushState navigation · open

On SPAs that use `history.pushState()` for routing (React Router, Vue Router, Next.js client-side navigation), `capture.navigation()` does not fire and `page.url()` returns the previous URL.

**Trigger:** any SPA route change via internal link click or `history.pushState()` directly.

**Does NOT affect:** full-page navigations (HTTP redirects, `location.href` assignments, `<a>` to external URLs).

**Workaround:** poll `page.url()` after a known delay, or compare before/after:
```python
# Python example
url_before = await page.url()
await page.find(role="link", text="Products").click()
await page.sleep(500)
url_after = await page.url()
assert url_after != url_before
```

Or use `page.evaluate("location.href")` which reads directly from the page context (always current).

**Sites affected:** any SPA — React/Next.js apps, Vue SPAs, Angular apps.

---

## Safe navigation patterns

```sh
# Standard navigation — works for most sites
vibium go https://example.com
vibium wait load

# SPA navigation — after clicking a link, don't rely on capture.navigation
vibium click "@e-nav-link"
vibium sleep 500
vibium url   # may still show previous URL if SPA (B126)
vibium eval 'location.href'   # always current

# PrestaShop subdomain — use eval instead of vibium go
vibium eval "location.href = 'https://demo.prestashop.com/en/...'"
vibium wait load --timeout 10000
```

## Related

→ [[methods/back]] · → [[methods/forward]] · → [[methods/reload]] · → [[patterns/dialog_deadlock]] · → [[bugs/cli#B3]]
