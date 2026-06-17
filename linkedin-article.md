# Mapping the Vibium API: An Interactive Knowledge Graph for Browser Automation

If you've used Vibium for browser automation, you know the challenge: five surfaces (CLI, MCP, JS, Python, Java), 148 commands, dozens of behavioral differences between them — and documentation spread across READMEs, release notes, and your own notes.

I built the **Vibium Knowledge Graph** to solve this. It's an open-source, interactive visualization of the entire Vibium API in one place, with two different ways to explore it.

---

## What it is

The wiki maps every Vibium command across all five surfaces into a single graph with 226 nodes:

**Vibium root → 5 surfaces → 17 categories → 148 commands + open bugs + patterns + references**

Every command node links to its own method page with cross-surface syntax tables, known bugs, and workarounds. Bug coverage spans CLI (B1–B33), MCP (MB1–MB10), JS, Python, and Java clients — including which bugs were fixed in v26.5.31.

---

## Two ways to explore

### Force-Directed Graph (`graph.html`)

The first view renders the graph in 3D using Three.js. Nodes arrange themselves by connection strength — commands cluster near their category, surfaces orbit the root, bugs attach to the commands that have them.

**What you can do:**
- Click any node to open a sidebar with CLI/MCP/JS/Python/Java syntax side by side
- Filter by group (surfaces, API commands, open bugs, fixed bugs, patterns, references)
- Isolate by tier — see only the commands available on all 5 surfaces, or just 3, or planned ones
- Focus on a single surface (CLI / MCP / JS / Python / Java) to highlight its coverage
- Search by name, description, or CLI syntax — an amber notice appears when your matches are hidden by active filters

This view is best for exploring connections: *which commands share a category? which bugs affect the same command? what's the CLI surface coverage vs Java?*

→ **Live:** https://lana-20.github.io/vibium-wiki/graph.html

### Layered Planes Graph (`graph-layered.html`)

The second view stacks the same 226 nodes into 6 horizontal planes using Three.js and OrbitControls. Each plane is a tier of the hierarchy — root at the bottom, fixed bugs and references at the top.

The camera orbits freely: left-drag to rotate, scroll to zoom, right-drag to pan.

**What you can do:**
- Toggle individual layers on/off
- Show or hide labels per layer or all at once
- Adjust vertical spacing between planes
- Click any node to open an info panel with description, group, and surface

This view is best for understanding hierarchy: *how deep is the command tree? how many commands exist at each tier? where do bugs concentrate?*

→ **Live:** https://lana-20.github.io/vibium-wiki/graph-layered.html

---

## New to it? Start with the guide

I wrote a two-fold guide that walks through both views side by side — which one to open, how to navigate, how to read nodes, and quick-reference tips for each.

→ **Guide:** https://lana-20.github.io/vibium-wiki/guide.html

---

## Under the hood

The graphs are backed by a structured wiki:
- **148 method pages** — one per command, with cross-surface syntax tables
- **Bug indexes** by client
- **Behavioral patterns** — dialog deadlock, negative value parsing, case-sensitive text find
- **Architecture and API reference** docs
- **Release notes** through v26.5.31

The whole thing is tested: the force-directed view has a 629-test suite (16 suites), the layered view has a 303-test suite (18 suites), both using Vibium CLI to automate the browser and assert graph state via JavaScript hooks.

---

## Why I built this

Systematic API coverage testing across five clients means constantly asking: *does this command exist in MCP? what's the Java equivalent? is this a known bug or my setup?*

I was credited in the Vibium v26.5.31 release notes for "an extraordinary amount of systematic, cross-client testing" — and this wiki is the artifact that made that testing possible. It started as personal notes and grew into something worth sharing.

If you're working with Vibium, or curious about how to build a knowledge graph for a multi-surface API, the repo is open:

→ **GitHub:** https://github.com/lana-20/vibium-wiki

Feedback, issues, and PRs welcome.
