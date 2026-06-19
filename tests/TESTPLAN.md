# Vibium Knowledge Graph — Test Plan

**Subject:** `graph.html`  
**Toolchain:** Vibium CLI (`/vibe-check` skill)  
**Last verified:** 2026-06-17 · v26.5.31  
**Runner:** `tests/run-tests.sh [url]`  
**Run history:** `tests/run-history.log` (one line per run); full output in `tests/runs/<ISO-timestamp>.txt`

---

## Graph data baseline

| Entity | Count |
|---|---|
| Total nodes | 226 |
| Surface nodes | 5 |
| Category nodes | 17 |
| Command nodes | 148 |
| Open bug nodes | 32 (bug-open + bug-partial + bug-regression) |
| Fixed bug nodes | 15 |
| Pattern nodes | 3 |
| Reference nodes | 5 |

Command tier breakdown: all5=72, 4surf=9, 3surf=54, 2surf=11, planned=2

---

## T1 — Node click / unclick (happy path)

**Applies to:** all 229 nodes across all groups.

### Click (first click on a node)

| Check | Expected |
|---|---|
| `#sidebar-placeholder` display | `none` |
| `#close-sidebar` display | not `none` (visible) |
| `#mode-badge` display | `block` |
| `#mode-badge` text | contains node name |
| `#sidebar-content` innerHTML | non-empty |
| `activeHighlight` | non-null |
| `lastClickedId` | equals `node.id` |

### Unclick (click same node again)

| Check | Expected |
|---|---|
| `#sidebar-placeholder` display | not `none` (visible) |
| `#close-sidebar` display | `none` |
| `#mode-badge` display | `none` |
| `#sidebar-content` innerHTML | empty |
| `activeHighlight` | `null` |
| `lastClickedId` | `null` |

### Sidebar group label per node type

| Group | Sidebar label | Badge contains |
|---|---|---|
| root | "Root" | node name |
| surface | "Surface" | "N commands" |
| category | "Category" | "use sidebar to collapse" |
| command | tier label | node name |
| bug-open / bug-partial / bug-regression | "Open Bug" | node name |
| bug-fixed | "Fixed Bug" | node name |
| pattern | "Pattern" | node name |
| reference | "Reference" | node name |

### Neighbor highlight count
- Root node click → 28 neighbors highlighted (5 surfaces + 17 categories + 5 references + root)
- Surface node click → all commands available on that surface + root + that surface node

### Node IDs reference

| Type | IDs |
|---|---|
| Root | `vibium` |
| Surfaces | `cli` `mcp` `js` `python` `java` |
| Categories (all 17) | `cat-browser` `cat-navigation` `cat-finding` `cat-waiting` `cat-interaction` `cat-reading` `cat-page-control` `cat-context` `cat-input` `cat-network` `cat-events` `cat-clock` `cat-recording` `cat-dialog` `cat-download` `cat-extras` `cat-ai` |
| Sampled bugs | `B1` `B3` `B6` `MCP-149` `JS-124` `PY-146` `JV-128` |
| Pattern | `p-dialog` |
| References | `r-arch` `r-action` `r-bidi` `r-roadmap` `r-ainative` |

> Category IDs follow `cat-<key>` where `<key>` is the object key in the `CATEGORIES` map, NOT a derivative of the category display name. Always derive IDs from `Graph.graphData().nodes.filter(n => n.group === 'category').map(n => n.id)`.

---

## T2 — Group filter buttons (happy path)

**Buttons:** `[data-group]` — surface, api, bug-open, bug-fixed, pattern, reference

### Toggle off

| Check | Expected |
|---|---|
| Button `.active` class | removed |
| Group in `activeFilters` | false |
| Corresponding node count in graph | 0 |

### Toggle on (restore)

| Check | Expected |
|---|---|
| Button `.active` class | present |
| Group in `activeFilters` | true |
| Node count restored | matches baseline |

### Expected node counts per group

| Group | Off | On |
|---|---|---|
| surface | 0 | 5 |
| api | 0 commands | 148 |
| bug-open | 0 | 32 |
| bug-fixed | 0 | 15 |
| pattern | 0 | 3 |
| reference | 0 | 5 |

---

## T3 — Tier filter buttons (happy path)

**Behavior:** mutually exclusive (radio). Default = none selected, all 148 commands visible.

### Default state

| Check | Expected |
|---|---|
| Any button with `.active` class | none |
| `activeTierFilter` | `null` |
| `activeTiers` contents | all 5 tiers |
| Command nodes in graph | 148 |

### Click to isolate

| Tier | Expected commands |
|---|---|
| all5 | 72 |
| 4surf | 9 |
| 3surf | 54 |
| 2surf | 11 |
| planned | 2 |

Per click: only that button active, `activeTierFilter` equals tier value, `activeTiers` is singleton set.

### Click same button (clear)

| Check | Expected |
|---|---|
| Button `.active` | removed |
| `activeTierFilter` | `null` |
| `activeTiers` | all 5 tiers |
| Command count | 148 |

### Switch between tiers (no intermediate clear)

1. Click tier A → tier A active
2. Click tier B → only tier B active, tier A deactivated, no stale state

---

## T4 — Surface focus buttons (happy path)

**Buttons:** `.surf-hi-btn[data-sid]` — cli, mcp, js, python, java

### Click to highlight

| Check | Expected |
|---|---|
| Button `.active` class | present |
| `activeSurfHi` | equals `data-sid` |
| `activeHighlight.type` | `"surface"` |
| Mode badge text | `"<Label>: N commands · click again to clear"` |

### Badge label per surface

| data-sid | Label in badge |
|---|---|
| cli | CLI |
| mcp | MCP |
| js | JS |
| python | Python |
| java | Java |

### Click same button (clear)

| Check | Expected |
|---|---|
| Button `.active` | removed |
| `activeSurfHi` | `null` |
| `activeHighlight` | `null` |
| Mode badge | hidden |

### Switch surfaces

Click CLI → click MCP: only MCP active, CLI deactivated (no double-highlight).

---

## T5 — Search (happy path)

**Element:** `#search` (use `vibium type` — appends; clear with eval before reuse)

### Match by field

| Query | Matched via | Min hits |
|---|---|---|
| `click` | name + desc + meta | 14 |
| `shadow` | desc | 2 |
| `clock` | name, mcp, js | 11 |
| `evaluate` | name | 5 |
| `deadlock` | desc | 5 |

### Case insensitivity

`CLICK` and `click` produce identical `highlightedIds`.

### Clear

Set `search.value = ""` + dispatch `input` event:
- `searchQuery === ""`
- `highlightedIds.size === 0`
- `#search-notice` hidden

---

## T6 — Search notice (happy path)

**Element:** `#search-notice`  
**Trigger:** matches hidden by active group/tier filter.

| Scenario | Expected notice |
|---|---|
| No query | hidden |
| Query, all filters on | hidden |
| Query + bug-open off | "4 matches hidden by filters" |
| Query + bug-open + api off | "9 matches hidden by filters" |
| Restore API | back to "4 matches hidden by filters" |
| Restore bug-open | hidden |
| Clear search | hidden |
| Query + All5 tier | "4 matches hidden by filters" |
| Query + Planned tier | "1 match hidden by filters" (singular) |

---

## T7 — Guide overlay (happy path)

| Action | Expected |
|---|---|
| Click `? Guide` | `#help-overlay` visible |
| Click `✕` inside overlay | `#help-overlay` hidden |
| Click backdrop outside `#help-inner` | `#help-overlay` hidden |
| Press `Escape` | `#help-overlay` hidden |

---

## T8 — Close sidebar button (happy path)

1. Click any node → sidebar shown, close button visible
2. Click `✕` → placeholder restored, badge hidden, `activeHighlight = null`, `lastClickedId = null`

---

## T9 — Compound / cross-feature interactions

Tests that multiple features compose correctly when active simultaneously.

| Scenario | Status | Expected |
|---|---|---|
| Search active + click a node | ✅ runner | sidebar shown, `activeHighlight` set, `searchQuery` preserved, `highlightedIds` intact |
| Tier filter active + click a node from that tier | ✅ runner | click/unclick works normally; tier filter still set after unclick |
| Tier filter active + click a node NOT in that tier | documented | node is not in graph; click not possible |
| Surface focus active + group filter off (api) | ✅ runner | surface focus badge still shows; 0 command nodes visible |
| Search + surface focus both active | ✅ runner | `searchQuery` non-empty and `activeSurfHi` set independently |
| Group filter off + tier filter active | ✅ runner | both `activeFilters` and `activeTierFilter` preserved; 0 commands visible |
| Click node → activate tier filter → unclick node | ✅ runner | unclick still clears sidebar and badge; tier filter preserved |
| Surface focus active → click different surface node | ✅ runner | `lastClickedId` = new node; `activeHighlight.type = 'surface'`; previous `activeSurfHi` unchanged |

---

## T10 — Negative cases

### Search: no match

| Input | Expected |
|---|---|
| `xyznothing` | `highlightedIds.size === 0` |
| Empty string `""` | `highlightedIds.size === 0`, `searchQuery === ""` |
| Single space `" "` | treated as empty after `.trim()`, same as clear |

### Filters: zero-result state

| Scenario | Expected graph state |
|---|---|
| All group filters off | 1 node — root node always visible (group `'root'` not covered by any filter button) |
| API group off | 0 command nodes; other groups unaffected |
| Tier filter active with no commands in graph (api off) | 0 commands regardless of tier |

### Tier: non-existent tier value

- No `data-tier` button for `client` or `climcp` (removed — 0 commands on those tiers)
- `activeTiers` never contains those values

### Click on non-interactive 3D canvas area

- `handleNodeClick` not called
- Sidebar state unchanged
- No badge change

---

## T11 — Edge cases

### Search edge cases

| Input | Expected behavior |
|---|---|
| `vibium clock` | 0 hits — clock has no CLI surface; `cli` field is `""` |
| `""` (programmatic clear) | clears highlight, hides notice |
| Field not present on node (`n.cli` undefined) | treated as `""` via `(n.cli\|\|'')` guard |
| Very long query (100+ chars) | no crash; 0 hits gracefully |
| Special chars `page.find({ role` | partial match against JS syntax fields |

### Filter edge cases

| Scenario | Expected |
|---|---|
| Toggle same group filter on/off rapidly | final state matches last click; no intermediate render crash |
| Toggle same tier button rapidly | `activeTierFilter` reflects last click; `activeTiers` correct |
| Tier switch mid-animation (before graph settles) | no crash; correct tier applied after settle |
| All groups off then back on | all 229 nodes restored |

### Node click edge cases

| Scenario | Expected |
|---|---|
| Click a node not currently in graph (hidden by filter) | not reachable via 3D canvas; handleNodeClick only reached via eval |
| Call handleNodeClick with undefined node | guard: `if (!node) return` expected |
| Click node while graph is still simulating | works; position values may differ but interaction state correct |

### Search notice edge cases

| Scenario | Expected |
|---|---|
| 1 hidden match | "1 match hidden by filters" (singular) |
| All matches hidden | shows full hidden count |
| Restore filter that uncovers all matches | notice hides immediately |

---

## T12 — Visual feedback / UI state

Verifies that visual state matches underlying data state (no ghost active classes, stale badges, etc.).

| Check | Method | Expected |
|---|---|---|
| Active tier button count | `querySelectorAll('.tier-btn.active').length` | 0 (default) or 1 (when selected) |
| Active surface focus button count | `querySelectorAll('.surf-hi-btn.active').length` | 0 or 1 |
| Group filter active buttons | `querySelectorAll('.filter-btn.active').length` | 6 (default) |
| Mode badge visible only when state is active | check `display` | `none` when no click/surface selected |
| Search notice amber color | `#f59e0b` in computed style | visual only — inspect in browser |
| Tier button color matches tier | `--tc` CSS variable set correctly per button | visual only |
| Sidebar width always 280px | not collapsed to 0 | `#sidebar` always visible |

---

## T13 — Accessibility (keyboard + ARIA)

| Scenario | Expected |
|---|---|
| `Escape` key closes guide overlay | `#help-overlay` hidden |
| `Escape` key when overlay not open | no error, no state change |
| Tab focus on header buttons | buttons are focusable via keyboard |
| `#search` input type="search" | native clear (×) button appears on focus with content |

---

## T14 — State isolation between test runs

Each test must leave the page in a clean state for the next. Teardown checklist:

```js
// Reset all filters to default
activeFilters = new Set(['surface','api','bug-open','bug-fixed','pattern','reference']);
activeTiers.clear(); ['all5','4surf','3surf','2surf','planned'].forEach(t => activeTiers.add(t));
activeTierFilter = null;
activeSurfHi = null;
activeHighlight = null;
lastClickedId = null;
searchQuery = '';
highlightedIds.clear();
document.getElementById('search').value = '';
document.getElementById('search-notice').style.display = 'none';
```

Or: `vibium reload` + `vibium sleep 2000` for a full reset.

---

## T15 — Runner-discovered bugs and data facts

Bugs and data facts discovered while building and running `run-tests.sh` — captured here so future maintainers understand why tests are written the way they are.

### Category node IDs do not match display names

Category node IDs follow `cat-<CATEGORIES-key>`, not a slug of the display name. The actual IDs confirmed from `Graph.graphData()`:

```
cat-browser  cat-navigation  cat-finding   cat-waiting   cat-interaction
cat-reading  cat-page-control cat-context  cat-input     cat-network
cat-events   cat-clock        cat-recording cat-dialog    cat-download
cat-extras   cat-ai
```

**Impact:** any test that hard-codes assumed IDs like `cat-nav`, `cat-read`, `cat-eval` will silently fail (node not in graph → handleNodeClick receives undefined → no-op).  
**Fix:** always derive IDs dynamically: `Graph.graphData().nodes.filter(n => n.group === 'category').map(n => n.id)`.

### Root node is not covered by any group filter

`groupVisible('root')` always returns `true` — the root node is exempt from all filter buttons. When all 6 group filter buttons are toggled off, `Graph.graphData().nodes.length === 1` (the root node remains).

**Impact:** tests that expect 0 nodes when all filters are off will fail. Expect 1.

### `cmd-click` is `all5` tier — unavailable when `3surf` tier is active

Testing "tier filter active + click a node" requires choosing a command that belongs to the active tier. `cmd-click` is `all5` (available on all 5 surfaces) and is removed from the graph when the `3surf` tier is selected. Use `cmd-b-page` or any other confirmed 3surf command instead.

**Fix pattern:** for tier-scoped node click tests, always confirm the command's `_tier` matches the active tier filter:  
`Graph.graphData().nodes.find(n => n._tier === '3surf')` — pick the first result.

### `vibium fill ""` fails (B20) — use `vibium type` for search input

`vibium fill ""` on the search input throws "value is required". Always use:
1. `vibium type "#search" "<text>"` to type into search (appends)
2. `document.getElementById('search').value=''; dispatchEvent(new Event('input'))` via eval to programmatically clear

### Bash associative arrays with hyphenated keys fail under `set -u`

`declare -A arr=([bug-open]=32)` followed by `${arr[$var]}` where `$var="bug-open"` throws `bug-open: unbound variable` under `set -euo pipefail`. Always use helper functions instead of associative arrays for mapped data in this script.

---

## Known non-bugs (data characteristics)

| Observation | Reason |
|---|---|
| `"vibium clock"` search → 0 hits | clock has no CLI surface; `cli` field is `""` by design |
| `client` / `climcp` tier buttons absent | 0 commands on exactly 1 surface in v26.5.31 dataset |
| Surface focus + tier filter: independent | surface focus highlights; tier filter scopes visibility; they compose without conflict |
| `highlightedIds` may contain hidden node IDs | search runs on `ALL_NODES`, not graph nodes; hidden matches shown in `#search-notice` |

---

---

## T14 — Category collapse

Tests `toggleCollapse()`, the sidebar collapse/expand button, and the `collapsedCats` Set.

| Scenario | Expected |
|---|---|
| Click category node | Sidebar shows "▼ Collapse commands" button; `.node-type` = "Category" |
| `collapsedCats` before collapse | empty / does not contain catId |
| Click collapse button | `collapsedCats.has(catId) === true`; category's command nodes removed from graph; sidebar shows "▶ Expand commands" |
| Click expand button | `collapsedCats.has(catId) === false`; command count restored; sidebar shows "▼ Collapse commands" |
| Collapse multiple categories simultaneously | all catIds in `collapsedCats`; all respective command nodes removed |
| Expand categories individually | each catId removed from `collapsedCats` on expand; `collapsedCats.size === 0` after all expanded |
| Search active + collapse a matching category | `#search-notice` appears (toggleCollapse calls updateSearchNotice) |

### Node ID note

The catId for `collapsedCats` is the CATEGORIES key (e.g. `'browser'`, `'navigation'`), not the node ID prefix (`cat-browser`). Command nodes have `catId` matching this key and `group === 'command'`. Always filter by `group === 'command'` when counting category commands — the category node itself also has `catId` set.

### AUT fix applied (2026-06-15)

`toggleCollapse` was not calling `updateSearchNotice()`, so the search notice did not update when a category was collapsed/expanded with a search active. Fixed by adding `updateSearchNotice()` call after `refreshGraph()`.

---

## T15 — Sidebar content verification

Verifies that each node group renders the correct content structure in `#sidebar-content`, beyond just "non-empty innerHTML" (which T1 checks).

| Group | Checks |
|---|---|
| command | `.node-type` text includes "API Method"; `.surf-table` present; `↗ docs` link present with correct `methods/` URL |
| category | `.node-type` text includes "Category"; sidebar button present; "commands" text in content; no docs link |
| surface | `.node-type` text includes "Surface"; "commands on this surface" in content |
| bug-open | `.node-type` text includes "Open"; `.workaround` element present (for bugs with workarounds) |
| root | `.node-type` text includes "Root" |

**Docs link URL mapping** (4 cases verified):

| Node | Expected URL |
|---|---|
| `cmd-click` (existing page) | `methods/click.md` |
| `cmd-b-start` (stub) | `methods/b-start.md` |
| `cmd-back` | `methods/back.md` |
| `cmd-scrollIV` (camelCase ID) | `methods/scroll-iv.md` |

Nodes used: `cmd-click`, `cmd-b-start`, `cmd-back`, `cmd-scrollIV`, `cat-interaction`, `cli`, `B3` (bug-open with workaround), `vibium` (root).

---

## T16 — Stats panel

Tests `#stats` live counts against `Graph.graphData()` state.

| Element | Default | After api off | After 3surf tier | After bug-open off | After bug-fixed off |
|---|---|---|---|---|---|
| `#stat-cmds` | `148/148` | `0/148` | `54/148` | `148/148` | `148/148` |
| `#stat-open` | `32` | `32` | `32` | `0` | `32` |
| `#stat-fixed` | `15` | `15` | `15` | `15` | `0` |
| `#stat-nodes` | `226` | — | — | — | — |

The denominator in `stat-cmds` is always `cmdNodes.length` (148) — total command count, not visible count. Dynamic check: `stat-nodes` text must equal `Graph.graphData().nodes.length` string.

---

## Test execution

```bash
cd ~/vibium-wiki/tests
./run-tests.sh
# or with custom URL:
./run-tests.sh http://localhost:3000/graph.html
```

Sources consulted for best practices:
- [Edge Case Testing Explained](https://www.virtuosoqa.com/post/edge-case-testing)
- [Filter UI and UX Design Best Practices](https://www.uxpin.com/studio/blog/filter-ui-and-ux/)
- [UI Testing Best Practices — test-states](https://github.com/NoriSte/ui-testing-best-practices/blob/master/sections/advanced/test-states.md)
- [Best Practices for UI Testing Frameworks](https://ambahera.medium.com/best-practices-for-ui-testing-frameworks-b02cfe676521)
