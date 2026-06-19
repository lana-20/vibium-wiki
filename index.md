# Vibium LLM Wiki

**Current version:** v26.5.31 (2026-06-01)  
**Last ingest:** 2026-06-14  
**Sources:** vibium-cli-test SKILL.md (B1–B33), vibium-mcp-test SKILL.md (MCP #149–MCP #157), vibium-js-test suite (JS #118, JS #123–JS #126), vibium-python-test suite (Py #146), vibium-java-test suite (JV #174, #129, #130, #135, #136, #137, #128, #106), GitHub issues (VibiumDev/vibium), v26.5.31 release notes, VibiumDev/vibium repo (README, ROADMAP, docs/, clients/)

---

## Bug indexes

| Index | Contents | Open | Fixed |
|---|---|---|---|
| [bugs/cli.md](bugs/cli.md) | B1–B33 CLI bugs | B3 B6 B8 B10–B22 B24–B33 | B1 B2 B4 B7 B9; B5/B30/B32 partial |
| [bugs/mcp.md](bugs/mcp.md) | MCP bugs (MCP #149–MCP #157) | MCP #151 | MCP #149 MCP #150 MCP #152–MCP #157 |
| [bugs/js.md](bugs/js.md) | JS client bugs (JS #118, JS #123–JS #126) | JS #124 JS #126 JS #118 | JS #123 JS #125 (fixed v26.5.31 #163) |
| [bugs/python.md](bugs/python.md) | Python client bugs | #146 | #168 #147 #145 #144 #110 + v26.3 era |
| [bugs/java.md](bugs/java.md) | Java client bugs | #174 #135 #128 #106 | 9 bugs fixed v26.5.31 |

---

## Method pages

| Method | CLI bugs | MCP bugs | Status |
|---|---|---|---|
| [click](methods/click.md) | B3 B6 | MCP #151 (deferred) | open |
| [dialog](methods/dlg-acc.md) | B3 | MCP #151 | open |
| [eval / evaluate](methods/evaluate.md) | B9 ✓ | MCP #154 ✓ | partial (JS #124 open) |
| [fill](methods/fill.md) | B7 ✓ B18 B20 B31 | MCP #155 ✓ | partial |
| [find](methods/find.md) | B15✓ B17 B29 | — | partial |
| [hover](methods/hover.md) | B30 partial | — | partial |
| [map](methods/map.md) | B16 B24 | — | open |
| [go](methods/go.md) | B3 JS #126 | — | open |
| [select](methods/select.md) | B5 partial | — | partial |
| [waitForFn / waitUntil](methods/wait-for-fn.md) | JS #123 (fixed v26.5.31) | — | fixed |
| [clock.install](methods/cl-inst.md) | JS #125 (fixed v26.5.31) | — | fixed |

All 148 commands have a page in [methods/](methods/) — one file per command. The pages above have full documentation with bug details and workarounds; all others have cross-surface syntax tables.

---

## Behavioral patterns

| Pattern | Summary |
|---|---|
| [dialog_deadlock](patterns/dialog_deadlock.md) | Socket-level deadlock on native dialogs/navigation — affects CLI, MCP, Python, Java, recording mode |
| [negative_values](patterns/negative_values.md) | Negative numbers parsed as flags — B14, B18, B22 |
| [find_text_case](patterns/find_text_case.md) | find text is case-sensitive against DOM text; CSS text-transform never applied — B15 regression-check |

---

## Releases

| Version | Date | Summary |
|---|---|---|
| [v26.5.31](releases/v26.5.31.md) | 2026-06-01 | Major bug-fix: npm dist, fill textarea, select errors, MCP serialization, Python/Java fixes |
| v26.3.18 | — | Previous release (npm package shipped without dist/) |

---

## Open GitHub issues (bugs only, not enhancements)

| # | Title | Client | Relates to |
|---|---|---|---|
| #174 | page.waitForFunction() Java double-wraps | Java | Java B3 |
| #129 | page.waitForURL() — `**/*.html` + regex patterns still fail after partial fix | Java | partial |
| #130 | page.addScript() — script null after go() (addScript→go() path still broken) | Java | partial |
| #136 | onError() — ErrorEvent + Promise.reject still not captured after partial fix | Java | partial |
| #137 | clock — ClockOptions.time() builder path still ignored after partial fix | Java | partial |
| #159 | vibium pipe fails with Selenium Grid | CLI | — |
| #158 | vibium pipe --connect disconnects immediately | CLI | — |
| MCP #151 | browser_click deadlocks on native dialog (MCP) | MCP | — |
| #146 | capture.dialog deadlocks in Python | Python | dialog_deadlock |
| #142 | vibium click hangs during recording on POST redirect | CLI | B3 variant |
| #135 | page.expose() never injects function | Java | — |
| #128 | page.route()/setHeaders() → go() deadlock | Java | dialog_deadlock |
| JS #126 | capture.navigation() misses SPA pushState | All | navigate |
| JS #124 | page.evaluate() wraps nested array strings | JS/Python/Java | evaluate |
| #112 | 33 CLI bugs (original report) | CLI | bugs/cli |
| #108 | Interaction scripts with semantic locators | CLI | — |
| #107 | HTTP 500 on browser session creation | CLI | — |
| #106 | SelectorOptions not applied in element lookup | Java | — |
| #98 | vibium install misses chromedriver | CLI | — |
| JS #118 | Pierce selector support for shadow DOM (enhancement) | All | map B16 |

---

## Reference

| Page | Contents |
|---|---|
| [reference/architecture.md](reference/architecture.md) | System diagram, CLI vs MCP, sync/async bridge, BiDi foundation, platform support, install paths |
| [reference/actionability.md](reference/actionability.md) | Five checks (visible/stable/receivesEvents/enabled/editable), per-action check sets, polling loop, semantic selectors |
| [reference/api-reference.md](reference/api-reference.md) | Full 148-command cross-surface table (CLI / MCP / JS / Python / Java) |
| [reference/api-surface.md](reference/api-surface.md) | Method counts per surface (CLI=66, MCP=85, JS=68, Python=72, Java=82), install links |
| [reference/bidi-coverage.md](reference/bidi-coverage.md) | WebDriver BiDi coverage tracker: 40/87 implemented (63 commands + 24 events) |
| [reference/ai-native.md](reference/ai-native.md) | Draft spec: `page.check()` and `page.do()` AI-powered methods (not yet implemented) |
| [reference/roadmap.md](reference/roadmap.md) | Cortex, Retina, AI locators, video recording, .NET client, additional browsers |
| [reference/public-docs.md](reference/public-docs.md) | daisyladybug.com API reference pages + vibewire issues + research links |

---

## Guides

| Guide | Contents |
|---|---|
| [guides/getting-started-js.md](guides/getting-started-js.md) | JS/TS install, sync and async API quickstart, troubleshooting |
| [guides/getting-started-mcp.md](guides/getting-started-mcp.md) | MCP setup for Claude Code / Gemini CLI, options, CLI vs MCP differences |
| [guides/recording.md](guides/recording.md) | Recording format, event types, chunks, zip structure, player.vibium.dev |

---

## Schema

See [SCHEMA.md](SCHEMA.md) for page conventions, status values, ingest rules, and lint rules.

---

## Knowledge Graphs

Two interactive views of the same 230-node dataset: root → 5 surfaces → 17 categories → 148 commands + 36 open bugs + 15 fixed bugs + 3 patterns + 5 references.

**Guide (start here):** https://lana-20.github.io/vibium-wiki/guide.html

---

### graph.html — Force-Directed View

**Live:** https://lana-20.github.io/vibium-wiki/graph.html  
**Tech:** 3d-force-graph (vasturiano / Three.js) · also opens locally via `file://`  
**Last updated:** 2026-06-14 · v26.5.31

3D force-directed graph. Nodes spring apart and attract based on connections — best for exploring relationships and neighbors.

**Features:**
- **Node click/unclick** — highlights neighbors, opens sidebar with CLI/MCP/JS/Python/Java syntax
- **Group filters** — toggle Surfaces / API / Open Bugs / Fixed Bugs / Patterns / References
- **Tier filters** — isolate by availability (All 5 / 4 surf / 3 surf / 2 surf / Planned); mutually exclusive
- **Surface Focus** — CLI / MCP / JS / Python / Java header buttons; highlights all commands on that surface
- **Search** — matches name, desc, meta, CLI syntax, MCP tool name; amber notice when matches are hidden by filters
- **Guide overlay** — `? Guide` button; closes via X, backdrop click, or Escape

**Test suite:**
```sh
cd ~/vibium-wiki/tests && ./run-tests.sh
# 629 / 629 pass (2026-06-17) — 16 suites
```

---

### graph-layered.html — Layered Planes View

**Live:** https://lana-20.github.io/vibium-wiki/graph-layered.html  
**Tech:** Three.js r161 · OrbitControls · CSS2DRenderer · also opens locally via `file://`  
**Last updated:** 2026-06-16 · v26.5.31

Same 230 nodes arranged as 6 stacked horizontal planes (root / surfaces / categories / commands / bugs+patterns / fixed+refs). Camera orbits freely via OrbitControls (left-drag rotate · scroll zoom · right-drag pan) — best for understanding hierarchy and tier structure.

**Features:**
- **Layer toggles** — show/hide each of the 6 planes independently
- **Per-layer label buttons** — toggle labels for one layer at a time
- **All Node Labels checkbox** — bulk on/off for all labels
- **Spacing slider** — adjust vertical gap between planes
- **L0–L5 ring markings** — CSS2D labels on each plane's outer ring
- **Node click info panel** — shows name, group, surface, description; close button deselects

**Test suite:**
```sh
cd ~/vibium-wiki/tests && bash run-layered-tests.sh
# 303 / 303 pass (2026-06-17) — 18 suites incl. T16b 360°/720° twirl
```

---

### Test files

| File | Contents |
|---|---|
| `tests/TESTPLAN.md` | Full test plan — 16 suites for graph.html + 18 suites for graph-layered.html |
| `tests/run-tests.sh` | **graph.html** runner (629 tests, 16 suites); auto-resolves vibium binary; saves to `runs/<timestamp>.txt` and `run-history.log` |
| `tests/run-layered-tests.sh` | **graph-layered.html** runner (303 tests, 18 suites); same output pattern as above |
| `tests/run-history.log` | One-line summary per run (both suites) |
| `tests/runs/` | Full stdout+stderr per run, timestamped (ISO UTC) |

**Skill:** `/vibium-wiki-test` (see `~/.claude/skills/vibium-wiki-test/SKILL.md`)
