# Vibium Wiki

Community knowledge base for [Vibium](https://vibium.dev) — browser automation across CLI, MCP, JS, Python, and Java. Covers API coverage, open bugs, behavioral patterns, and release notes through v26.5.31.

---

## Knowledge Graph Mindmap

`graph.html` — view on GitHub Pages or open locally:

**Graph:** https://lana-20.github.io/vibium-wiki/graph.html · **Guide:** https://lana-20.github.io/vibium-wiki/guide.html

```sh
open graph.html
```

Interactive 3D force graph of all 148 Vibium commands across 5 surfaces (CLI / MCP / JS / Python / Java). 226 nodes total: root → surfaces → categories → commands + bugs + patterns + references.

**Features:** node click for sidebar with per-surface syntax · group/tier filters · surface focus buttons · search with hidden-match notice · ? Guide overlay

---

## Contents

| Section | What's inside |
|---|---|
| [index.md](index.md) | Full table of contents |
| [bugs/](bugs/) | B1–B33 CLI · MB1–MB10 MCP · JS · Python · Java bug indexes |
| [methods/](methods/) | 148 per-method pages — one per command; all have syntax tables, key commands have full docs |
| [patterns/](patterns/) | dialog_deadlock · negative_values · find_text_case |
| [reference/](reference/) | Architecture · actionability · full API cross-surface table · BiDi coverage · roadmap |
| [guides/](guides/) | Getting started with JS/TS and MCP · recording format |
| [releases/](releases/) | v26.5.31 release notes |
| [SCHEMA.md](SCHEMA.md) | Page conventions, status values, ingest and lint rules |

---

## Test suite

```sh
cd tests && ./run-tests.sh
# 629 / 629 pass — saves output to runs/<timestamp>.txt and run-history.log
```

See [tests/TESTPLAN.md](tests/TESTPLAN.md) for 18 test sections covering the mindmap UI.

---

**Version:** v26.5.31 · **Last ingest:** 2026-06-14
