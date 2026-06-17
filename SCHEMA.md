# Vibium LLM Wiki — Schema

## Purpose

This wiki is the single source of truth for Vibium behavioral knowledge: known bugs, workarounds, version-specific status, and non-obvious quirks. An LLM maintains it; humans curate the raw sources and do the testing.

## Directory layout

```
vibium-wiki/
├── SCHEMA.md          ← this file
├── index.md           ← full wiki index
├── bugs/
│   ├── cli.md         ← B1–B33 index
│   ├── mcp.md         ← MB1–MB10 index
│   ├── js.md          ← JS client bugs (Bug 1–4 + #118)
│   ├── python.md      ← Python client bugs
│   └── java.md        ← Java client bugs
├── methods/
│   ├── <148 files — one per command>
│   ├── click.md, evaluate.md, fill.md, find.md, hover.md, map.md, select.md
│   ├── go.md, back.md, forward.md, reload.md, url.md, title.md, bring.md, pg-close.md
│   ├── wait-for.md, sleep.md, wait-for-fn.md, wait-url.md, wait-load.md, wait-text.md, wait-until.md
│   ├── cl-inst.md, cl-ff.md, cl-run-f.md, cl-p-at.md, cl-res.md, cl-s-fixed.md, cl-s-sys.md, cl-s-tz.md
│   └── dlg-acc.md, dlg-dis.md, dlg-msg.md, dlg-type.md, dlg-dv.md
├── patterns/
│   └── <name>.md      ← cross-cutting behavioral patterns
├── reference/
│   ├── architecture.md     ← system diagram, sync/async bridge, BiDi
│   ├── actionability.md    ← five checks, polling loop, semantic selectors
│   ├── api-reference.md    ← 148-command cross-surface table
│   ├── api-surface.md      ← method counts per surface, install links
│   ├── bidi-coverage.md    ← BiDi spec coverage tracker (40/87)
│   ├── ai-native.md        ← draft: page.check() / page.do() spec
│   ├── roadmap.md          ← Cortex, Retina, AI locators, etc.
│   └── public-docs.md      ← daisyladybug.com references + vibewire
├── guides/
│   ├── getting-started-js.md   ← JS/TS quickstart
│   ├── getting-started-mcp.md  ← MCP setup (Claude Code / Gemini CLI)
│   └── recording.md            ← recording format, chunks, player
└── releases/
    └── v26.5.31.md        ← full release notes
```

## Page frontmatter

Every method page must have:

```yaml
---
method: <vibium-command>      # e.g. fill, find, hover
aliases: []                   # MCP equivalent names if any, e.g. [browser_fill]
last_tested: <version>        # e.g. v26.5.31
last_tested_date: <YYYY-MM-DD>
bugs: [B7, B18, B20, B31]    # bug IDs from bugs/cli.md or bugs/mcp.md
status: stable | partial | open | untested
---
```

Every bug-index entry must have: ID, severity, priority, status, version-introduced (if known), version-fixed (if known), affected method(s), workaround reference.

## Status values

| Status | Meaning |
|---|---|
| `open` | Bug confirmed present in last tested version |
| `fixed` | Bug confirmed resolved in last tested version |
| `partial` | Some sub-cases fixed, others remain |
| `regression-check` | Previously fixed; keep test to catch re-introduction |
| `intermittent` | Not consistently reproducible; hypothesized root cause noted |
| `untested` | No test run against current version |

## Ingest rules

When new test results arrive:
1. Update `bugs/cli.md` or `bugs/mcp.md` status for each affected bug
2. Update the `last_tested` / `last_tested_date` in the method page frontmatter
3. If a bug is newly fixed: change status to `fixed`, add `version-fixed`, add workaround note "(no longer needed as of vX)"
4. If a bug is newly introduced: add entry to bugs index, add to method page `bugs:` list
5. If a workaround is no longer needed: mark it "(deprecated since vX)" but do not remove it — historical record matters

## Query conventions

To answer "does X work on Y?": read the method page → check bug list for open issues → check patterns for cross-cutting constraints.

To answer "what's the workaround for Z?": grep bug index for Z → follow bug ID to method page → read workaround section.

## Lint rules (run periodically)

- If a bug is `fixed` but the regression suite still labels it FAIL → flag contradiction
- If a method page `bugs:` list references a bug ID not in the index → orphaned reference
- If a bug index entry references a method page that does not exist → missing page
- If a workaround references another method that is also bugged → cross-bug dependency, note it
- If `last_tested_date` is more than 60 days old → flag as stale

## Cross-reference syntax

Use `→ [[methods/fill]]` to link to a method page.
Use `→ [[bugs/cli#B7]]` to link to a specific bug entry.
Use `→ [[patterns/dialog_deadlock]]` to link to a pattern page.

Links that don't resolve yet are placeholders — not errors.

## Version history

| Version | Date | Notable changes |
|---|---|---|
| v26.5.31 | 2026-06-01 | Fill textarea fixed (B7/MB7), select errors on non-match + label matching (B5), eval JSON fixed (B9/MB6), MCP: count/storage/cookies/annotate/get_attribute/get_text fixed (MB1-MB9 except MB3/MB10), Python: eval alias, BoundingBox dict, large pipe; Java: 9 method fixes. See [releases/v26.5.31.md](releases/v26.5.31.md) |
| v26.3.18 | — | Previous release — npm package shipped without dist/ (broken) |

## GitHub issues cross-reference

| Issue | Bug ID | Status |
|---|---|---|
| #174 | Java B3 | open — Java client double-wraps waitForFunction |
| #151 | MB3 | open — MCP browser_click dialog deadlock |
| #146 | Python #146 | open — capture.dialog deadlock (Python) |
| #142 | B3 variant | open — recording mode POST redirect deadlock |
| #128 | Java #128 | open — page.route()/setHeaders() navigation deadlock |
| #126 | navigate #126 | open — SPA pushState navigation not captured |
| #124 | evaluate #124 | open — nested array strings wrapped as BiDi typed objects |
| #118 | B16 enhancement | open — pierce selector for shadow DOM |
| #112 | B1–B33 | open — original CLI bug report |
| #117 | B7 | closed v26.5.31 — fill textarea CLI |
| #155 | MB7 | closed v26.5.31 — fill textarea MCP |
| #140 | B5 | closed v26.5.31 — select label matching + error on miss |
| #149 | MB1 | closed v26.5.31 — browser_count type mismatch |
| #150 | MB2 | closed v26.5.31 — browser_storage_state cookie parse |
| #152 | MB4 | closed v26.5.31 — browser_set_cookie domain |
| #153 | MB5 | closed v26.5.31 — browser_get_attribute null/absent |
| #154 | MB6 | closed v26.5.31 — browser_evaluate empty string |
| #156 | MB8 | closed v26.5.31 — browser_screenshot annotate crash |
| #157 | MB9 | closed v26.5.31 — browser_get_text empty text |
| #173 | — | closed — vibium click obscured on var.parts (real overlay, not false positive) |
