# Vibium Wiki

Community knowledge base for [Vibium](https://vibium.dev) — browser automation across CLI, MCP, JS, Python, and Java. Covers API coverage, open bugs, behavioral patterns, and release notes through v26.5.31.

---

## Guide

New to the knowledge graphs? Start here:

**https://lana-20.github.io/vibium-wiki/guide.html**

Step-by-step instructions for both views — which graph to open, how to navigate, filter, and read nodes. Covers force-directed and layered planes side by side.

---

## Knowledge Graph — Force-Directed View

`graph.html` — view on GitHub Pages or open locally:

**Graph:** https://lana-20.github.io/vibium-wiki/graph.html

```sh
open graph.html
```

Interactive 3D force graph of all 148 Vibium commands across 5 surfaces (CLI / MCP / JS / Python / Java). 230 nodes total: root → surfaces → categories → commands + bugs + patterns + references.

**Features:** node click for sidebar with per-surface syntax · group/tier filters · surface focus buttons · search with hidden-match notice · ? Guide overlay

---

## Knowledge Graph — Layered Planes View

`graph-layered.html` — view on GitHub Pages or open locally:

**Layered graph:** https://lana-20.github.io/vibium-wiki/graph-layered.html

```sh
open graph-layered.html
```

Same 230-node dataset rendered as 6 horizontal planes stacked in Three.js. Camera orbits freely via OrbitControls (left-drag rotate · scroll zoom · right-drag pan). Each plane is a node tier: root / surfaces / categories / commands / bugs+patterns / fixed+refs.

**Features:** layer visibility toggles · per-layer label buttons · spacing slider · L0–L5 ring markings · node click info panel

---

## Contents

| Section | What's inside |
|---|---|
| [index.md](index.md) | Full table of contents |
| [bugs/](bugs/) | B1–B33 CLI · #149–#157 + MB10 MCP · JS · Python · Java bug indexes |
| [methods/](methods/) | 148 per-method pages — one per command; all have syntax tables, key commands have full docs |
| [patterns/](patterns/) | dialog_deadlock · negative_values · find_text_case |
| [reference/](reference/) | Architecture · actionability · full API cross-surface table · BiDi coverage · roadmap |
| [guides/](guides/) | Getting started with JS/TS and MCP · recording format |
| [releases/](releases/) | v26.5.31 release notes |
| [SCHEMA.md](SCHEMA.md) | Page conventions, status values, ingest and lint rules |

---

## Test suites

**Force-directed view** (`graph.html`):
```sh
cd tests && ./run-tests.sh
# 629 / 629 pass — saves output to runs/<timestamp>.txt and run-history.log
```

**Layered planes view** (`graph-layered.html`):
```sh
cd tests && bash run-layered-tests.sh
# 303 / 303 pass — 18 suites including camera controls and 360°/720° twirl tests
```

See [tests/TESTPLAN.md](tests/TESTPLAN.md) for full test plan coverage.

---

**Version:** v26.5.31 · **Last ingest:** 2026-06-14
