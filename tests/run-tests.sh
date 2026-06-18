#!/usr/bin/env bash
# Vibium Knowledge Graph — automated test runner
# Usage: ./run-tests.sh [url]
# Requires: vibium CLI on PATH

set -euo pipefail

URL="${1:-file://$(cd "$(dirname "$0")/.." && pwd)/graph.html}"

VIB=vibium
command -v vibium &>/dev/null || { echo "ERROR: vibium not found in PATH" >&2; exit 1; }

# ── Logging setup ────────────────────────────────────────────────────────────
RUNS_DIR="$(dirname "$0")/runs"
mkdir -p "$RUNS_DIR"
RUN_TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
RUN_LOG="$RUNS_DIR/$RUN_TS.txt"
exec > >(tee "$RUN_LOG") 2>&1

# ── Assertion framework ───────────────────────────────────────────────────────
PASS=0; FAIL=0; SUITE_FAIL=0

pass() { echo "  ✓ $1"; ((PASS++)) || true; }
fail() { echo "  ✗ $1"; echo "    expected: $3  got: $2"; ((FAIL++)) || true; ((SUITE_FAIL++)) || true; }

assert() {
  local label="$1" actual="$2" expected="$3"
  [[ "$actual" == "$expected" ]] && pass "$label" || fail "$label" "$actual" "$expected"
}

# Run a JS expression via vibium eval, return its output
ev() { $VIB eval "$1" 2>/dev/null || echo "EVAL_ERROR"; }

suite() {
  SUITE_FAIL=0
  echo ""
  echo "━━ $1"
}

# Reset page state without a full reload (faster between suites)
reset_state() {
  ev "
    activeFilters = new Set(['surface','api','bug-open','bug-fixed','pattern','reference']);
    activeTiers.clear(); ['all5','4surf','3surf','2surf','planned'].forEach(function(t){activeTiers.add(t)});
    activeTierFilter = null;
    activeSurfHi = null;
    activeHighlight = null;
    lastClickedId = null;
    searchQuery = '';
    highlightedIds.clear();
    document.getElementById('search').value = '';
    document.getElementById('search-notice').style.display = 'none';
    document.querySelectorAll('.filter-btn').forEach(function(b){
      b.classList.toggle('active', true);
    });
    document.querySelectorAll('.tier-btn').forEach(function(b){b.classList.remove('active')});
    document.querySelectorAll('.surf-hi-btn').forEach(function(b){b.classList.remove('active')});
    refreshGraph();
    'reset'
  " > /dev/null
}

# Click a node by id via handleNodeClick
click_node() { ev "handleNodeClick(Graph.graphData().nodes.find(function(n){return n.id==='$1'})); 'ok'"; }

# ── Boot ──────────────────────────────────────────────────────────────────────
echo "Vibium Knowledge Graph — Test Runner"
echo "URL: $URL"
echo "VIB: $VIB"
$VIB go "$URL"
$VIB sleep 3000
echo "Page loaded."

# ── T1: Node click / unclick ──────────────────────────────────────────────────
suite "T1 — Node click / unclick"

check_click_unclick() {
  local id="$1" label="$2"
  click_node "$id" > /dev/null
  assert "$label — placeholder hidden"        "$(ev "document.getElementById('sidebar-placeholder').style.display")"  "none"
  assert "$label — close-btn visible"         "$(ev "document.getElementById('close-sidebar').style.display !== 'none' ? 'ok' : 'hidden'")"  "ok"
  assert "$label — mode-badge visible"        "$(ev "document.getElementById('mode-badge').style.display")"  "block"
  assert "$label — sidebar-content non-empty" "$(ev "document.getElementById('sidebar-content').innerHTML.trim().length > 0 ? 'ok' : 'empty'")"  "ok"
  assert "$label — activeHighlight non-null"  "$(ev "activeHighlight !== null ? 'ok' : 'null'")"  "ok"
  assert "$label — lastClickedId set"         "$(ev "lastClickedId === '$id' ? 'ok' : lastClickedId")"  "ok"

  click_node "$id" > /dev/null
  assert "$label — unclick: placeholder restored" "$(ev "document.getElementById('sidebar-placeholder').style.display !== 'none' ? 'ok' : 'hidden'")"  "ok"
  assert "$label — unclick: close-btn hidden"     "$(ev "document.getElementById('close-sidebar').style.display")"  "none"
  assert "$label — unclick: mode-badge hidden"    "$(ev "document.getElementById('mode-badge').style.display")"  "none"
  assert "$label — unclick: sidebar cleared"      "$(ev "document.getElementById('sidebar-content').innerHTML.trim().length === 0 ? 'ok' : 'not-empty'")"  "ok"
  assert "$label — unclick: activeHighlight null" "$(ev "activeHighlight === null ? 'ok' : 'set'")"  "ok"
  assert "$label — unclick: lastClickedId null"   "$(ev "lastClickedId === null ? 'ok' : lastClickedId")"  "ok"
}

check_click_unclick "vibium"  "root"
check_click_unclick "cli"     "surface: cli"
check_click_unclick "mcp"     "surface: mcp"
check_click_unclick "js"      "surface: js"
check_click_unclick "python"  "surface: python"
check_click_unclick "java"    "surface: java"

# All 17 categories
reset_state
for cat in cat-browser cat-navigation cat-finding cat-waiting cat-interaction \
           cat-reading cat-page-control cat-context cat-input cat-network \
           cat-events cat-clock cat-recording cat-dialog cat-download \
           cat-extras cat-ai; do
  check_click_unclick "$cat" "category: $cat"
done

# Batch-check all command nodes via single eval
reset_state
cmd_results=$(ev "
(function(){
  var nodes = Graph.graphData().nodes.filter(function(n){return n.group==='command'});
  var pass=[]; var fail=[];
  nodes.forEach(function(n){
    handleNodeClick(n);
    var ok = activeHighlight !== null &&
             lastClickedId === n.id &&
             document.getElementById('sidebar-content').innerHTML.trim().length > 0;
    if(!ok) fail.push(n.id + '(click)');
    handleNodeClick(n);
    var ok2 = activeHighlight === null && lastClickedId === null;
    if(!ok2) fail.push(n.id + '(unclick)');
  });
  return fail.length === 0 ? 'PASS:' + nodes.length : 'FAIL:' + fail.join(',');
}())
")
if [[ "$cmd_results" == PASS:* ]]; then
  pass "all ${cmd_results#PASS:} command nodes — click/unclick"
else
  fail "command node click/unclick batch" "$cmd_results" "PASS:148"
fi

# Sample bug, pattern, reference nodes
reset_state
for nid in B1 B3 B6 MCP-149 JS-124 PY-146 JV-128 p-dialog r-arch r-bidi; do
  check_click_unclick "$nid" "node: $nid"
done

# ── T2: Group filter buttons ──────────────────────────────────────────────────
suite "T2 — Group filter buttons"
reset_state

group_test() {
  local grp="$1" q="$2" expected="$3"
  ev "document.querySelector('[data-group=\"${grp}\"]').click()" > /dev/null
  assert "$grp off — removed from activeFilters" "$(ev "activeFilters.has('$grp') ? 'yes' : 'no'")" "no"
  assert "$grp off — button loses .active"       "$(ev "document.querySelector('[data-group=\"${grp}\"]').classList.contains('active') ? 'yes' : 'no'")" "no"
  assert "$grp off — node count = 0"             "$(ev "var g=Graph.graphData().nodes; ${q} + ''")" "0"
  ev "document.querySelector('[data-group=\"${grp}\"]').click()" > /dev/null
  assert "$grp on — restored to activeFilters"   "$(ev "activeFilters.has('$grp') ? 'yes' : 'no'")" "yes"
  assert "$grp on — button gains .active"        "$(ev "document.querySelector('[data-group=\"${grp}\"]').classList.contains('active') ? 'yes' : 'no'")" "yes"
  assert "$grp on — node count = $expected"      "$(ev "var g=Graph.graphData().nodes; ${q} + ''")" "$expected"
}

group_test "surface"   "g.filter(function(n){return n.group==='surface'}).length"                                                                              "5"
group_test "api"       "g.filter(function(n){return n.group==='command'}).length"                                                                              "148"
group_test "bug-open"  "g.filter(function(n){return n.group==='bug-open'||n.group==='bug-partial'||n.group==='bug-regression'}).length"                        "36"
group_test "bug-fixed" "g.filter(function(n){return n.group==='bug-fixed'}).length"                                                                            "15"
group_test "pattern"   "g.filter(function(n){return n.group==='pattern'}).length"                                                                              "3"
group_test "reference" "g.filter(function(n){return n.group==='reference'}).length"                                                                            "5"

# Combination: api + bug-open both off
ev "document.querySelector('[data-group=api]').click()" > /dev/null
ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
assert "api+bug-open off — commands = 0" "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "0"
assert "api+bug-open off — bugOpen = 0"  "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='bug-open'||n.group==='bug-partial'||n.group==='bug-regression'}).length + ''")" "0"
ev "document.querySelector('[data-group=api]').click()" > /dev/null
ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
assert "api+bug-open restored — commands = 148" "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "148"

# ── T3: Tier filter buttons ───────────────────────────────────────────────────
suite "T3 — Tier filter buttons (mutually exclusive)"
reset_state

assert "default — no tier button active"  "$(ev "[...document.querySelectorAll('.tier-btn.active')].length + ''")" "0"
assert "default — activeTierFilter null"  "$(ev "activeTierFilter === null ? 'ok' : activeTierFilter")" "ok"
assert "default — 148 commands visible"   "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "148"

tier_test() {
  local tier="$1" expected="$2"
  ev "document.querySelector('[data-tier=\"${tier}\"]').click()" > /dev/null
  assert "$tier — activeTierFilter set"      "$(ev "activeTierFilter === '$tier' ? 'ok' : activeTierFilter")" "ok"
  assert "$tier — only this button active"   "$(ev "[...document.querySelectorAll('.tier-btn.active')].map(function(b){return b.dataset.tier}).join(',')")" "$tier"
  assert "$tier — command count = $expected" "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "$expected"
  ev "document.querySelector('[data-tier=\"${tier}\"]').click()" > /dev/null
  assert "$tier cleared — activeTierFilter null"  "$(ev "activeTierFilter === null ? 'ok' : activeTierFilter")" "ok"
  assert "$tier cleared — no active tier buttons" "$(ev "[...document.querySelectorAll('.tier-btn.active')].length + ''")" "0"
  assert "$tier cleared — 148 commands restored"  "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "148"
}

tier_test "all5"    "72"
tier_test "4surf"   "9"
tier_test "3surf"   "54"
tier_test "2surf"   "11"
tier_test "planned" "2"

# Switch: all5 → 3surf without clearing
ev "document.querySelector('[data-tier=all5]').click()" > /dev/null
ev "document.querySelector('[data-tier=\"3surf\"]').click()" > /dev/null
assert "switch all5→3surf — only 3surf active" "$(ev "[...document.querySelectorAll('.tier-btn.active')].map(function(b){return b.dataset.tier}).join(',')")" "3surf"
assert "switch all5→3surf — 54 commands"       "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "54"
ev "document.querySelector('[data-tier=\"3surf\"]').click()" > /dev/null

# ── T4: Surface focus buttons ─────────────────────────────────────────────────
suite "T4 — Surface focus buttons"
reset_state

surf_test() {
  local sid="$1" label="$2"
  ev "document.querySelector('[data-sid=\"${sid}\"]').click()" > /dev/null
  assert "$sid — activeSurfHi set"        "$(ev "activeSurfHi === '$sid' ? 'ok' : String(activeSurfHi)")" "ok"
  assert "$sid — button gains .active"    "$(ev "document.querySelector('[data-sid=\"${sid}\"]').classList.contains('active') ? 'ok' : 'no'")" "ok"
  assert "$sid — activeHighlight.type"    "$(ev "activeHighlight && activeHighlight.type === 'surface' ? 'ok' : 'no'")" "ok"
  assert "$sid — badge contains label"    "$(ev "document.getElementById('mode-badge').textContent.includes('$label') ? 'ok' : document.getElementById('mode-badge').textContent")" "ok"
  assert "$sid — badge visible"           "$(ev "document.getElementById('mode-badge').style.display")" "block"
  ev "document.querySelector('[data-sid=\"${sid}\"]').click()" > /dev/null
  assert "$sid cleared — activeSurfHi null"    "$(ev "activeSurfHi === null ? 'ok' : String(activeSurfHi)")" "ok"
  assert "$sid cleared — button loses .active" "$(ev "document.querySelector('[data-sid=\"${sid}\"]').classList.contains('active') ? 'yes' : 'ok'")" "ok"
  assert "$sid cleared — activeHighlight null" "$(ev "activeHighlight === null ? 'ok' : 'set'")" "ok"
  assert "$sid cleared — badge hidden"         "$(ev "document.getElementById('mode-badge').style.display")" "none"
}

surf_test "cli"    "CLI"
surf_test "mcp"    "MCP"
surf_test "js"     "JS"
surf_test "python" "Python"
surf_test "java"   "Java"

# Switch: cli → mcp
ev "document.querySelector('[data-sid=cli]').click()" > /dev/null
ev "document.querySelector('[data-sid=mcp]').click()" > /dev/null
assert "switch cli→mcp — only mcp active" "$(ev "[...document.querySelectorAll('.surf-hi-btn.active')].map(function(b){return b.dataset.sid}).join(',')")" "mcp"
ev "document.querySelector('[data-sid=mcp]').click()" > /dev/null

# ── T5: Search ────────────────────────────────────────────────────────────────
suite "T5 — Search"
reset_state

clear_search() {
  ev "document.getElementById('search').value=''; document.getElementById('search').dispatchEvent(new Event('input'))" > /dev/null
}

# match by name
$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search 'click' — hits >= 14"       "$(ev "highlightedIds.size >= 14 ? 'ok' : highlightedIds.size + ''")" "ok"
assert "search 'click' — cmd-click in set" "$(ev "highlightedIds.has('cmd-click') ? 'ok' : 'no'")" "ok"
clear_search

# match by desc
$VIB type "#search" "shadow" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search 'shadow' — hits = 2"  "$(ev "highlightedIds.size + ''")" "2"
clear_search

# case insensitive
$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
HITS_LOWER=$(ev "highlightedIds.size + ''")
clear_search
$VIB type "#search" "CLICK" 2>/dev/null; $VIB sleep 200 2>/dev/null
HITS_UPPER=$(ev "highlightedIds.size + ''")
assert "search case-insensitive — CLICK == click" "$HITS_UPPER" "$HITS_LOWER"
clear_search

# no match
$VIB type "#search" "xyznothing" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search no-match — highlightedIds empty" "$(ev "highlightedIds.size + ''")" "0"
clear_search

# empty string = clear
$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
clear_search
assert "search clear — query empty"     "$(ev "searchQuery")" ""
assert "search clear — no highlighted"  "$(ev "highlightedIds.size + ''")" "0"

# vibium clock → 0 hits (clock has no CLI surface; expected behavior, not a bug)
$VIB type "#search" "vibium clock" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search 'vibium clock' — 0 hits (no CLI surface)" "$(ev "highlightedIds.size + ''")" "0"
clear_search

# ── T6: Search notice ─────────────────────────────────────────────────────────
suite "T6 — Search notice"
reset_state

notice() { ev "document.getElementById('search-notice').style.display || 'visible'"; }
notice_text() { ev "document.getElementById('search-notice').textContent"; }

assert "no query — notice hidden" "$(notice)" "none"

$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "all filters on — notice hidden" "$(notice)" "none"

ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
assert "bug-open off — notice visible"   "$(notice)" "visible"
assert "bug-open off — notice text"      "$(notice_text)" "4 matches hidden by filters"

ev "document.querySelector('[data-group=api]').click()" > /dev/null
assert "api off too — notice updates"    "$(notice_text)" "9 matches hidden by filters"

ev "document.querySelector('[data-group=api]').click()" > /dev/null
assert "api restored — notice back to 4" "$(notice_text)" "4 matches hidden by filters"

ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
assert "bug-open restored — notice hidden" "$(notice)" "none"

clear_search
assert "search cleared — notice hidden" "$(notice)" "none"

# singular form
$VIB type "#search" "evaluate" 2>/dev/null; $VIB sleep 200 2>/dev/null
ev "document.querySelector('[data-tier=planned]').click()" > /dev/null
assert "1 hidden — singular form" "$(notice_text)" "1 match hidden by filters"
ev "document.querySelector('[data-tier=planned]').click()" > /dev/null
clear_search

# ── T7: Guide overlay ─────────────────────────────────────────────────────────
suite "T7 — Guide overlay"
reset_state

ev "document.getElementById('help-btn').click()" > /dev/null
assert "open — overlay visible"      "$(ev "document.getElementById('help-overlay').style.display !== 'none' ? 'ok' : 'hidden'")" "ok"

ev "document.getElementById('close-help').click()" > /dev/null
assert "close via X — overlay hidden" "$(ev "document.getElementById('help-overlay').style.display")" "none"

ev "document.getElementById('help-btn').click()" > /dev/null
ev "document.getElementById('help-overlay').dispatchEvent(new MouseEvent('click',{bubbles:true,target:document.getElementById('help-overlay')}))" > /dev/null
# backdrop click fires on the overlay itself (not inner)
ev "document.getElementById('help-overlay').click()" > /dev/null
assert "close via backdrop — overlay hidden" "$(ev "document.getElementById('help-overlay').style.display")" "none"

ev "document.getElementById('help-btn').click()" > /dev/null
ev "document.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}))" > /dev/null
assert "close via Escape — overlay hidden" "$(ev "document.getElementById('help-overlay').style.display")" "none"

# ── T8: Close sidebar button ──────────────────────────────────────────────────
suite "T8 — Close sidebar button"
reset_state

click_node "cmd-click" > /dev/null
assert "sidebar open — close-btn visible" "$(ev "document.getElementById('close-sidebar').style.display !== 'none' ? 'ok' : 'hidden'")" "ok"
ev "document.getElementById('close-sidebar').click()" > /dev/null
assert "after close — placeholder restored"    "$(ev "document.getElementById('sidebar-placeholder').style.display !== 'none' ? 'ok' : 'hidden'")" "ok"
assert "after close — badge hidden"            "$(ev "document.getElementById('mode-badge').style.display")" "none"
assert "after close — activeHighlight null"    "$(ev "activeHighlight === null ? 'ok' : 'set'")" "ok"
assert "after close — lastClickedId null"      "$(ev "lastClickedId === null ? 'ok' : lastClickedId")" "ok"

# ── T9: Compound / cross-feature interactions ─────────────────────────────────
suite "T9 — Compound interactions"
reset_state

# Tier filter active + click a node in that tier (cmd-b-page is 3surf)
ev "document.querySelector('[data-tier=\"3surf\"]').click()" > /dev/null
click_node "cmd-b-page" > /dev/null
assert "tier+click — sidebar shown"     "$(ev "document.getElementById('sidebar-content').innerHTML.trim().length > 0 ? 'ok' : 'empty'")" "ok"
assert "tier+click — tier still set"    "$(ev "activeTierFilter")" "3surf"
click_node "cmd-b-page" > /dev/null
ev "document.querySelector('[data-tier=\"3surf\"]').click()" > /dev/null

# Surface focus + group filter off
ev "document.querySelector('[data-sid=cli]').click()" > /dev/null
ev "document.querySelector('[data-group=api]').click()" > /dev/null
assert "surfFocus+api-off — commands = 0"          "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "0"
assert "surfFocus+api-off — surface focus intact"  "$(ev "activeSurfHi")" "cli"
ev "document.querySelector('[data-group=api]').click()" > /dev/null
ev "document.querySelector('[data-sid=cli]').click()" > /dev/null

# Search + group filter: notice updates when filter changes post-search
$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
BEFORE=$(ev "highlightedIds.size + ''")
ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
AFTER_HIDDEN=$(ev "highlightedIds.size + ''")
assert "search+filter — highlightedIds unchanged after filter toggle" "$AFTER_HIDDEN" "$BEFORE"
assert "search+filter — notice appears"                               "$(ev "document.getElementById('search-notice').style.display || 'visible'")" "visible"
ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
clear_search

# Click node → tier filter → unclick
click_node "cmd-fill" > /dev/null
ev "document.querySelector('[data-tier=all5]').click()" > /dev/null
click_node "cmd-fill" > /dev/null
assert "click→tier→unclick — sidebar cleared"      "$(ev "document.getElementById('sidebar-content').innerHTML.trim().length === 0 ? 'ok' : 'not-empty'")" "ok"
assert "click→tier→unclick — tier filter preserved" "$(ev "activeTierFilter")" "all5"
ev "document.querySelector('[data-tier=all5]').click()" > /dev/null

# T9-5: Search active + click a node — both states coexist
$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search+click — query set before click"    "$(ev "searchQuery !== '' ? 'ok' : 'empty'")" "ok"
assert "search+click — hits non-empty"            "$(ev "highlightedIds.size > 0 ? 'ok' : 'empty'")" "ok"
click_node "cmd-click" > /dev/null
assert "search+click — sidebar shown after click" "$(ev "document.getElementById('sidebar-content').innerHTML.trim().length > 0 ? 'ok' : 'empty'")" "ok"
assert "search+click — activeHighlight set"       "$(ev "activeHighlight !== null ? 'ok' : 'null'")" "ok"
assert "search+click — searchQuery preserved"     "$(ev "searchQuery !== '' ? 'ok' : 'lost'")" "ok"
click_node "cmd-click" > /dev/null
clear_search

# T9-6: Search + surface focus both active — independent state
$VIB type "#search" "click" 2>/dev/null; $VIB sleep 200 2>/dev/null
ev "document.querySelector('[data-sid=js]').click()" > /dev/null
assert "search+surfFocus — searchQuery non-empty"    "$(ev "searchQuery !== '' ? 'ok' : 'empty'")" "ok"
assert "search+surfFocus — activeSurfHi = js"        "$(ev "activeSurfHi")" "js"
assert "search+surfFocus — highlightedIds non-empty" "$(ev "highlightedIds.size > 0 ? 'ok' : 'empty'")" "ok"
assert "search+surfFocus — activeHighlight non-null" "$(ev "activeHighlight !== null ? 'ok' : 'null'")" "ok"
ev "document.querySelector('[data-sid=js]').click()" > /dev/null
clear_search

# T9-7: Group filter off + tier filter active — both states preserved
ev "document.querySelector('[data-group=\"api\"]').click()" > /dev/null
ev "document.querySelector('[data-tier=all5]').click()" > /dev/null
assert "grpOff+tier — api filter off"     "$(ev "activeFilters.has('api') ? 'on' : 'ok'")" "ok"
assert "grpOff+tier — tierFilter = all5"  "$(ev "activeTierFilter")" "all5"
assert "grpOff+tier — 0 commands visible" "$(ev "Graph.graphData().nodes.filter(function(n){return n.group==='command'}).length + ''")" "0"
ev "document.querySelector('[data-group=\"api\"]').click()" > /dev/null
ev "document.querySelector('[data-tier=all5]').click()" > /dev/null

# T9-8: Surface focus → click a different surface node — node click overrides highlight
ev "document.querySelector('[data-sid=cli]').click()" > /dev/null
assert "surfFocus→nodeClick — activeSurfHi cli before" "$(ev "activeSurfHi")" "cli"
click_node "mcp" > /dev/null
assert "surfFocus→nodeClick — lastClickedId = mcp"     "$(ev "lastClickedId")" "mcp"
assert "surfFocus→nodeClick — highlight type surface"  "$(ev "activeHighlight !== null && activeHighlight.type === 'surface' ? 'ok' : 'no'")" "ok"
click_node "mcp" > /dev/null
ev "document.querySelector('[data-sid=cli]').click()" > /dev/null

# ── T10: Negative cases ───────────────────────────────────────────────────────
suite "T10 — Negative cases"
reset_state

# Search: empty string
$VIB type "#search" " " 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search space — treated as empty" "$(ev "searchQuery === '' ? 'ok' : searchQuery")" "ok"
clear_search

# All group filters off → only root node remains (root group is not covered by any filter)
for grp in surface api bug-open bug-fixed pattern reference; do
  ev "document.querySelector('[data-group=\"${grp}\"]').click()" > /dev/null
done
assert "all groups off — only root node remains" "$(ev "Graph.graphData().nodes.length + ''")" "1"
assert "all groups off — remaining node is root"  "$(ev "Graph.graphData().nodes[0].group")" "root"
for grp in surface api bug-open bug-fixed pattern reference; do
  ev "document.querySelector('[data-group=\"${grp}\"]').click()" > /dev/null
done
assert "all groups restored — 230 nodes" "$(ev "Graph.graphData().nodes.length + ''")" "230"

# Client/CLI-MCP tier buttons absent
assert "no 'client' tier button in DOM"  "$(ev "document.querySelector('[data-tier=client]') ? 'found' : 'ok'")" "ok"
assert "no 'climcp' tier button in DOM"  "$(ev "document.querySelector('[data-tier=climcp]') ? 'found' : 'ok'")" "ok"

# ── T11: Edge cases ───────────────────────────────────────────────────────────
suite "T11 — Edge cases"
reset_state

# Special chars in search
$VIB type "#search" "page.find" 2>/dev/null; $VIB sleep 200 2>/dev/null
assert "search 'page.find' — no crash"  "$(ev "typeof highlightedIds.size === 'number' ? 'ok' : 'crash'")" "ok"
clear_search

# Rapidly toggle same tier button
ev "document.querySelector('[data-tier=all5]').click(); document.querySelector('[data-tier=all5]').click(); activeTierFilter === null ? 'ok' : activeTierFilter" > /dev/null
assert "rapid tier toggle — ends null" "$(ev "activeTierFilter === null ? 'ok' : activeTierFilter")" "ok"

# Search notice: singular "match" not "matches"
$VIB type "#search" "evaluate" 2>/dev/null; $VIB sleep 200 2>/dev/null
ev "document.querySelector('[data-tier=planned]').click()" > /dev/null
assert "notice singular — no trailing s" "$(ev "document.getElementById('search-notice').textContent.includes('1 match hidden') && !document.getElementById('search-notice').textContent.includes('1 matches') ? 'ok' : document.getElementById('search-notice').textContent")" "ok"
ev "document.querySelector('[data-tier=planned]').click()" > /dev/null
clear_search

# ── T12: Visual / UI state ────────────────────────────────────────────────────
suite "T12 — Visual and UI state"
reset_state

assert "default — 6 filter buttons active"          "$(ev "[...document.querySelectorAll('.filter-btn.active')].length + ''")" "6"
assert "default — 0 tier buttons active"            "$(ev "[...document.querySelectorAll('.tier-btn.active')].length + ''")" "0"
assert "default — 0 surf-hi buttons active"         "$(ev "[...document.querySelectorAll('.surf-hi-btn.active')].length + ''")" "0"
assert "default — mode-badge hidden"                "$(ev "document.getElementById('mode-badge').style.display")" "none"
assert "default — search-notice hidden"             "$(ev "document.getElementById('search-notice').style.display || 'none'")" "none"
assert "sidebar always visible — width not 0"       "$(ev "parseInt(getComputedStyle(document.getElementById('sidebar')).width) > 0 ? 'ok' : '0'")" "ok"
assert "sidebar placeholder visible by default"     "$(ev "document.getElementById('sidebar-placeholder').style.display !== 'none' ? 'ok' : 'hidden'")" "ok"
assert "5 tier buttons exist"                       "$(ev "document.querySelectorAll('.tier-btn').length + ''")" "5"
assert "5 surf-hi buttons exist"                    "$(ev "document.querySelectorAll('.surf-hi-btn').length + ''")" "5"
assert "6 filter-btn buttons exist"                 "$(ev "document.querySelectorAll('.filter-btn').length + ''")" "6"

# ── T13: Accessibility ────────────────────────────────────────────────────────
suite "T13 — Accessibility"
reset_state

# Escape closes guide overlay
ev "document.getElementById('help-btn').click()" > /dev/null
ev "document.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}))" > /dev/null
assert "Escape closes guide overlay" "$(ev "document.getElementById('help-overlay').style.display")" "none"

# Escape when overlay not open — no crash
ev "document.dispatchEvent(new KeyboardEvent('keydown',{key:'Escape',bubbles:true}))" > /dev/null
assert "Escape with no overlay — no crash" "$(ev "typeof activeHighlight + ''")" "object"

# search input type="search"
assert "search input type=search" "$(ev "document.getElementById('search').type")" "search"

# ── T14: Category collapse ────────────────────────────────────────────────────
suite "T14 — Category collapse"
reset_state

# Basic collapse/expand cycle — cat-browser
click_node "cat-browser" > /dev/null
assert "cat collapse — node-type is Category"    "$(ev "document.querySelector('#sidebar-content .node-type').textContent.includes('Category') ? 'ok' : 'no'")" "ok"
assert "cat collapse — collapse btn present"     "$(ev "document.getElementById('sidebar-content').innerHTML.includes('Collapse commands') ? 'ok' : 'no'")" "ok"
assert "cat collapse — not collapsed yet"        "$(ev "collapsedCats.has('browser') ? 'yes' : 'ok'")" "ok"

CMD_BEFORE=$(ev "Graph.graphData().nodes.filter(function(n){return n.catId==='browser' && n.group==='command'}).length + ''")

ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "cat collapse — collapsedCats has browser"  "$(ev "collapsedCats.has('browser') ? 'ok' : 'no'")" "ok"
assert "cat collapse — browser cmds removed"       "$(ev "Graph.graphData().nodes.filter(function(n){return n.catId==='browser' && n.group==='command'}).length + ''")" "0"
assert "cat collapse — sidebar shows expand btn"   "$(ev "document.getElementById('sidebar-content').innerHTML.includes('Expand commands') ? 'ok' : 'no'")" "ok"

ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "cat expand — collapsedCats cleared"        "$(ev "collapsedCats.has('browser') ? 'still-in' : 'ok'")" "ok"
assert "cat expand — browser cmds restored"        "$(ev "Graph.graphData().nodes.filter(function(n){return n.catId==='browser' && n.group==='command'}).length + ''")" "$CMD_BEFORE"
assert "cat expand — sidebar shows collapse btn"   "$(ev "document.getElementById('sidebar-content').innerHTML.includes('Collapse commands') ? 'ok' : 'no'")" "ok"

# Multiple collapses — navigation + browser simultaneously
ev "closeSidebar()" > /dev/null
click_node "cat-navigation" > /dev/null
ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "multi collapse — navigation collapsed"  "$(ev "collapsedCats.has('navigation') ? 'ok' : 'no'")" "ok"

ev "closeSidebar()" > /dev/null
click_node "cat-browser" > /dev/null
ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "multi collapse — browser collapsed"     "$(ev "collapsedCats.has('browser') ? 'ok' : 'no'")" "ok"
assert "multi collapse — both in collapsedCats" "$(ev "collapsedCats.has('browser') && collapsedCats.has('navigation') ? 'ok' : 'no'")" "ok"

ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "multi expand — browser expanded"        "$(ev "!collapsedCats.has('browser') ? 'ok' : 'no'")" "ok"

ev "closeSidebar()" > /dev/null
click_node "cat-navigation" > /dev/null
ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "multi expand — navigation expanded"     "$(ev "!collapsedCats.has('navigation') ? 'ok' : 'no'")" "ok"
assert "multi expand — collapsedCats empty"     "$(ev "collapsedCats.size === 0 ? 'ok' : 'no'")" "ok"

# Collapse + search notice: collapse cat-clock while searching for 'clock'
$VIB type "#search" "clock" 2>/dev/null; $VIB sleep 200 2>/dev/null
ev "closeSidebar()" > /dev/null
click_node "cat-clock" > /dev/null
ev "document.querySelector('#sidebar-content button').click()" > /dev/null
assert "collapse+search — notice appears when cmds hidden" "$(ev "document.getElementById('search-notice').style.display !== 'none' ? 'ok' : 'no'")" "ok"
ev "document.querySelector('#sidebar-content button').click()" > /dev/null
clear_search

# ── T15: Sidebar content verification ─────────────────────────────────────────
suite "T15 — Sidebar content"
reset_state

# Command node — surf-table, node-type label, docs link
click_node "cmd-click" > /dev/null
assert "sidebar cmd — node-type API Method" "$(ev "document.querySelector('#sidebar-content .node-type').textContent.includes('API Method') ? 'ok' : 'no'")" "ok"
assert "sidebar cmd — surf-table rendered"  "$(ev "document.querySelector('#sidebar-content .surf-table') !== null ? 'ok' : 'no'")" "ok"
assert "sidebar cmd — docs link present"    "$(ev "document.querySelector('#sidebar-content a[href*=\"methods/\"]') !== null ? 'ok' : 'no'")" "ok"
assert "sidebar cmd — docs link URL correct" "$(ev "document.querySelector('#sidebar-content a[href*=\"methods/\"]').href")" "https://github.com/lana-20/vibium-wiki/blob/main/methods/click.md"
ev "closeSidebar()" > /dev/null

# Docs link URL mapping — stub node (b-start → b-start.md)
click_node "cmd-b-start" > /dev/null
assert "docs link — stub node b-start.md"   "$(ev "document.querySelector('#sidebar-content a[href*=\"methods/\"]').href")" "https://github.com/lana-20/vibium-wiki/blob/main/methods/b-start.md"
ev "closeSidebar()" > /dev/null

# Docs link URL mapping — back now has its own page (back → back.md)
click_node "cmd-back" > /dev/null
assert "docs link — back→back.md" "$(ev "document.querySelector('#sidebar-content a[href*=\"methods/\"]').href")" "https://github.com/lana-20/vibium-wiki/blob/main/methods/back.md"
ev "closeSidebar()" > /dev/null

# Docs link URL mapping — camelCase ID (scrollIV → scroll-iv.md)
click_node "cmd-scrollIV" > /dev/null
assert "docs link — camelCase scrollIV→scroll-iv.md" "$(ev "document.querySelector('#sidebar-content a[href*=\"methods/\"]').href")" "https://github.com/lana-20/vibium-wiki/blob/main/methods/scroll-iv.md"
ev "closeSidebar()" > /dev/null

# Docs link absent on non-command nodes (category, surface, bug)
click_node "cat-interaction" > /dev/null
assert "docs link — absent on category node" "$(ev "document.querySelector('#sidebar-content a[href*=\"methods/\"]') === null ? 'ok' : 'present'")" "ok"
ev "closeSidebar()" > /dev/null

# Category node — node-type, collapse button, commands count text
click_node "cat-interaction" > /dev/null
assert "sidebar cat — node-type Category"        "$(ev "document.querySelector('#sidebar-content .node-type').textContent.includes('Category') ? 'ok' : 'no'")" "ok"
assert "sidebar cat — collapse btn present"      "$(ev "document.querySelector('#sidebar-content button') !== null ? 'ok' : 'no'")" "ok"
assert "sidebar cat — commands count in content" "$(ev "document.getElementById('sidebar-content').innerHTML.includes('commands') ? 'ok' : 'no'")" "ok"
ev "closeSidebar()" > /dev/null

# Surface node — node-type and per-surface command count
click_node "cli" > /dev/null
assert "sidebar surf — node-type Surface"              "$(ev "document.querySelector('#sidebar-content .node-type').textContent.includes('Surface') ? 'ok' : 'no'")" "ok"
assert "sidebar surf — commands on this surface text"  "$(ev "document.getElementById('sidebar-content').innerHTML.includes('commands on this surface') ? 'ok' : 'no'")" "ok"
ev "closeSidebar()" > /dev/null

# Bug-open node with workaround (B3 — dialog deadlock)
click_node "B3" > /dev/null
assert "sidebar bug-open — node-type Open"        "$(ev "document.querySelector('#sidebar-content .node-type').textContent.includes('Open') ? 'ok' : 'no'")" "ok"
assert "sidebar bug-open — workaround rendered"   "$(ev "document.querySelector('#sidebar-content .workaround') !== null ? 'ok' : 'no'")" "ok"
ev "closeSidebar()" > /dev/null

# Root node
click_node "vibium" > /dev/null
assert "sidebar root — node-type Root" "$(ev "document.querySelector('#sidebar-content .node-type').textContent.includes('Root') ? 'ok' : 'no'")" "ok"
ev "closeSidebar()" > /dev/null

# ── T16: Stats panel ──────────────────────────────────────────────────────────
suite "T16 — Stats panel"
reset_state

# Default state values
assert "stats default — cmds = 148/148" "$(ev "document.getElementById('stat-cmds').textContent")" "148/148"
assert "stats default — open = 36"      "$(ev "document.getElementById('stat-open').textContent")" "36"
assert "stats default — fixed = 15"     "$(ev "document.getElementById('stat-fixed').textContent")" "15"
assert "stats default — nodes = 230"    "$(ev "document.getElementById('stat-nodes').textContent")" "230"

# Dynamic: stat-nodes text matches Graph.graphData().nodes.length
assert "stats — nodes match graph data" "$(ev "document.getElementById('stat-nodes').textContent === Graph.graphData().nodes.length + '' ? 'ok' : 'mismatch'")" "ok"

# After api group off: visible commands drop to 0
ev "document.querySelector('[data-group=\"api\"]').click()" > /dev/null
assert "stats api-off — cmds = 0/148" "$(ev "document.getElementById('stat-cmds').textContent")" "0/148"
ev "document.querySelector('[data-group=\"api\"]').click()" > /dev/null

# After 3surf tier: only 54 commands visible
ev "document.querySelector('[data-tier=\"3surf\"]').click()" > /dev/null
assert "stats 3surf — cmds = 54/148" "$(ev "document.getElementById('stat-cmds').textContent")" "54/148"
ev "document.querySelector('[data-tier=\"3surf\"]').click()" > /dev/null

# After bug-open group off
ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null
assert "stats bug-open-off — open = 0" "$(ev "document.getElementById('stat-open').textContent")" "0"
ev "document.querySelector('[data-group=\"bug-open\"]').click()" > /dev/null

# After bug-fixed group off
ev "document.querySelector('[data-group=\"bug-fixed\"]').click()" > /dev/null
assert "stats bug-fixed-off — fixed = 0" "$(ev "document.getElementById('stat-fixed').textContent")" "0"
ev "document.querySelector('[data-group=\"bug-fixed\"]').click()" > /dev/null

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PASS + FAIL))
echo "Results: $PASS / $TOTAL passed  ($FAIL failed)"
if [[ $FAIL -eq 0 ]]; then
  echo "All tests passed ✓"
else
  echo "Some tests FAILED ✗"
fi

# ── Record run ────────────────────────────────────────────────────────────────
HISTORY_FILE="$(dirname "$0")/run-history.log"
echo "$RUN_TS  $PASS / $TOTAL passed  ($FAIL failed)  → runs/$RUN_TS.txt" >> "$HISTORY_FILE"
echo "Saved → $RUN_LOG"

$VIB daemon stop 2>/dev/null || true

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
