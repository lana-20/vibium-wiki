# Pattern: Dialog / Navigation Deadlock

## Summary

The most dangerous cross-cutting pattern in Vibium. A BiDi socket-level deadlock occurs whenever a command triggers a blocking event (native dialog, page navigation, form POST redirect) that the socket cannot follow while still waiting for the command to return.

**Affects:** CLI (B3), MCP (MB3 · #151), Python (#146), Java (#128), CLI recording mode (#142).

---

## Trigger taxonomy

| Trigger | Clients | Issue |
|---|---|---|
| `click` on element that fires `alert` / `confirm` / `prompt` | CLI, MCP | B3, MB3, #151 |
| `capture.dialog(fn)` where `fn` awaits the click | Python (JS SDK via capture API) | #146 |
| `click` during recording when form POST redirects back to same page | CLI | #142 |
| `page.route()` or `page.setHeaders()` then `page.go()` — server-side interception blocks navigation | Java | #128 |
| `vibium go` to a PrestaShop subdomain page (navigation event deadlocks socket) | CLI | B3 |
| Form `submit` that causes full-page navigation | CLI | B3 |

---

## Safe patterns

### CLI / MCP — pre-stub dialogs before clicking

```sh
# CLI
vibium eval 'window.alert = () => {}; window.confirm = () => true; window.prompt = () => "text"'
vibium click "@e1"   # dialog fires but is intercepted by JS — no BiDi involvement

# MCP
browser_evaluate { expression: "window.alert = () => {}; window.confirm = () => true" }
browser_click { selector: "@e1" }
```

Pre-stub return values are observed by page JS — useful for testing confirm-dependent flows.

### MCP — setTimeout approach

```
browser_evaluate { expression: "setTimeout(() => alert('msg'), 300)" }
browser_dialog_accept {}
```

The evaluate returns before the setTimeout fires, so the socket is free when the dialog appears.

### CLI — navigation workaround (PrestaShop / form POST)

```sh
# Do NOT use:  vibium go "https://subdomain.prestashop.com/page"
# Do NOT use:  vibium click "@nav-link"  (if link navigates away)

# Use instead:
vibium eval "location.href = 'https://target-url/path'"
vibium wait load --timeout 10000
```

### Python — capture.dialog fire-and-forget

Inside `capture.dialog()`, the callback must NOT await the click. The capture handler resolves its promise but does not dismiss the dialog — awaiting creates deadlock.

```python
# WRONG — deadlocks
async def trigger():
    await page.find(role="button", text="Alert").click()

async with page.capture.dialog() as dlg:
    await trigger()

# CORRECT — fire-and-forget
async def trigger():
    page.find(role="button", text="Alert").click()  # no await

async with page.capture.dialog() as dlg:
    await trigger()
```

Same rule applies in the JS SDK `capture.dialog(fn)` pattern.

### Java — avoid route/setHeaders before navigation

```java
// WRONG — deadlocks on page.go()
page.setHeaders(Map.of("X-Custom", "value"));
page.go("https://example.com");   // hangs forever

// WORKAROUND — inject headers via evaluate after navigation
page.go("https://example.com");
// headers cannot be set retroactively for the current page via this API
// use eval workaround or avoid setHeaders entirely
```

---

## Recovery

```sh
# CLI
pkill -f vibium && sleep 2 && vibium daemon start && sleep 2

# MCP
browser_stop {}
browser_start {}
# allow ~30s before force-quitting

# Python / Java
# kill the process; re-instantiate client
```

---

## Status by client (v26.5.31)

| Client | Status | Tracking |
|---|---|---|
| CLI | open | B3 |
| MCP | open · deferred | #151 / MB3 |
| Python capture.dialog | open | #146 |
| CLI recording mode | open | #142 |
| Java route/setHeaders | open | #128 |

No fix timeline announced for any of these as of 2026-06-14.

→ [[methods/dialog]] · → [[methods/click]] · → [[bugs/cli#B3]] · → [[bugs/mcp#MB3]]
