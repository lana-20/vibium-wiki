---
method: addScript
category: network
last_tested: v26.5.31
bugs: [JV-130]
status: partial
---

# addScript

Add script tag to page (⬜ CLI/MCP).

## Syntax

| Surface | Syntax |
|---|---|
| CLI | `⬜` |
| MCP | `⬜` |
| JS | `page.addScript()` |
| Python | `page.add_script()` |
| Java | `page.addScript()` |

## Known issues

**JV-130 — partial (#130):** Java `addScript()` param key fixed (PR #167). Residual: `addScript → go()` path still broken — script is null after navigation. Only `setContent → addScript → evaluate` path works.

**Workaround:** inject script after navigation via `page.evaluate()` with the script content directly.

→ [[bugs/java#130]] · → [[reference/api-reference]]
