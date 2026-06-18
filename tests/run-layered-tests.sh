#!/usr/bin/env bash
# Vibium Knowledge Graph — Layered View test runner
# Usage: ./run-layered-tests.sh [url]
# Requires: vibium CLI

set -euo pipefail

URL="${1:-file://$(cd "$(dirname "$0")/.." && pwd)/graph-layered.html}"

VIB=vibium
command -v vibium &>/dev/null || { echo "ERROR: vibium not found in PATH" >&2; exit 1; }

# ── Logging ───────────────────────────────────────────────────────────────────
RUNS_DIR="$(dirname "$0")/runs"
mkdir -p "$RUNS_DIR"
RUN_TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
RUN_LOG="$RUNS_DIR/layered-$RUN_TS.txt"
exec > >(tee "$RUN_LOG") 2>&1

# ── Assertion framework ───────────────────────────────────────────────────────
PASS=0; FAIL=0; SUITE_FAIL=0

pass() { echo "  ✓ $1"; ((PASS++)) || true; }
fail() { echo "  ✗ $1"; echo "    expected: $3  got: $2"; ((FAIL++)) || true; ((SUITE_FAIL++)) || true; }

assert() {
  local label="$1" actual="$2" expected="$3"
  [[ "$actual" == "$expected" ]] && pass "$label" || fail "$label" "$actual" "$expected"
}

ev() { $VIB eval "$1" 2>/dev/null || echo "EVAL_ERROR"; }

suite() {
  SUITE_FAIL=0
  echo ""
  echo "━━ $1"
}

sel()   { ev "_LG.selectNode(_LG.getMesh('$1')); 'ok'"; }
desel() { ev "_LG.deselectAll(); 'ok'"; }

# ── Boot ──────────────────────────────────────────────────────────────────────
echo "Vibium Knowledge Graph — Layered View Tests"
echo "URL: $URL"
echo "VIB: $VIB"
$VIB go "$URL"
$VIB sleep 4000
# Clear any pointer state that a previously interrupted run may have left in OrbitControls
ev "document.querySelector('canvas').dispatchEvent(new PointerEvent('pointercancel',{pointerId:1,bubbles:true})); 'ok'" > /dev/null
echo "Page loaded."

# ── T1: Data integrity ────────────────────────────────────────────────────────
suite "T1 — Data integrity"

assert "allNodes total = 230"       "$(ev "_LG.allNodes.length + ''")"  "230"
assert "layer 0 nodes = 1 (root)"   "$(ev "_LG.allNodes.filter(function(n){return n.layer===0}).length + ''")"  "1"
assert "layer 1 nodes = 5 (surf)"   "$(ev "_LG.allNodes.filter(function(n){return n.layer===1}).length + ''")"  "5"
assert "layer 2 nodes = 17 (cat)"   "$(ev "_LG.allNodes.filter(function(n){return n.layer===2}).length + ''")"  "17"
assert "layer 3 nodes = 148 (cmd)"  "$(ev "_LG.allNodes.filter(function(n){return n.layer===3}).length + ''")"  "148"
assert "layer 4 nodes = 39 (bugs+patterns)"  "$(ev "_LG.allNodes.filter(function(n){return n.layer===4}).length + ''")"  "39"
assert "layer 5 nodes = 20 (fixed+refs)"     "$(ev "_LG.allNodes.filter(function(n){return n.layer===5}).length + ''")"  "20"
assert "LAYER_DEFS length = 6"      "$(ev "_LG.LAYER_DEFS.length + ''")"  "6"
assert "meshes count = 230"         "$(ev "_LG.meshes.length + ''")"  "230"
assert "edgeLines exist"            "$(ev "_LG.edgeLines.length > 0 ? 'ok' : '0'")"  "ok"

# Group counts
assert "group root = 1"          "$(ev "_LG.allNodes.filter(function(n){return n.group==='root'}).length + ''")"      "1"
assert "group surface = 5"       "$(ev "_LG.allNodes.filter(function(n){return n.group==='surface'}).length + ''")"   "5"
assert "group category = 17"     "$(ev "_LG.allNodes.filter(function(n){return n.group==='category'}).length + ''")"  "17"
assert "group command = 148"     "$(ev "_LG.allNodes.filter(function(n){return n.group==='command'}).length + ''")"   "148"
assert "group bug-open = 29"     "$(ev "_LG.allNodes.filter(function(n){return n.group==='bug-open'}).length + ''")"  "29"
assert "group bug-partial = 6"   "$(ev "_LG.allNodes.filter(function(n){return n.group==='bug-partial'}).length + ''")"  "6"
assert "group bug-regression = 1" "$(ev "_LG.allNodes.filter(function(n){return n.group==='bug-regression'}).length + ''")"  "1"
assert "group pattern = 3"       "$(ev "_LG.allNodes.filter(function(n){return n.group==='pattern'}).length + ''")"   "3"
assert "group bug-fixed = 15"    "$(ev "_LG.allNodes.filter(function(n){return n.group==='bug-fixed'}).length + ''")" "15"
assert "group reference = 5"     "$(ev "_LG.allNodes.filter(function(n){return n.group==='reference'}).length + ''")"  "5"

# nodeMap contains key nodes
for nid in vibium cli mcp js python java cmd-click cmd-go B3 MCP-151 p-dialog r-arch JS-123; do
  assert "nodeMap has '$nid'"  "$(ev "_LG.nodeMap['$nid'] ? 'ok' : 'missing'")"  "ok"
done

# ── T2: Node positions ────────────────────────────────────────────────────────
suite "T2 — Node positions"

assert "root _x = 0"  "$(ev "_LG.nodeMap['vibium']._x + ''")"  "0"
assert "root _z = 0"  "$(ev "_LG.nodeMap['vibium']._z + ''")"  "0"

# Surfaces spread around a circle — none should be at (0,0) except root
assert "surfaces not all at origin"  \
  "$(ev "_LG.allNodes.filter(function(n){return n.group==='surface'&&n._x===0&&n._z===0}).length + ''")"  "0"

# Categories spread — at least 2 distinct _x values
assert "categories have spread _x values"  \
  "$(ev "(function(){var xs=_LG.allNodes.filter(function(n){return n.group==='category'}).map(function(n){return n._x}); return new Set(xs).size > 2 ? 'ok' : 'too-few'}())")"  "ok"

# Commands: all have _x and _z defined (not undefined)
assert "all commands have _x defined"  \
  "$(ev "_LG.allNodes.filter(function(n){return n.group==='command'&&typeof n._x==='undefined'}).length + ''")"  "0"
assert "all commands have _z defined"  \
  "$(ev "_LG.allNodes.filter(function(n){return n.group==='command'&&typeof n._z==='undefined'}).length + ''")"  "0"

# Layer Y positions at default SPACING=90
assert "layer 0 Y = 0"    "$(ev "_LG.getMesh('vibium').mesh.position.y + ''")"  "0"
assert "layer 1 Y = 90"   "$(ev "_LG.getMesh('cli').mesh.position.y + ''")"  "90"
assert "layer 2 Y = 180"  "$(ev "_LG.getMesh('cat-browser').mesh.position.y + ''")"  "180"
assert "layer 3 Y = 270"  "$(ev "_LG.getMesh('cmd-click').mesh.position.y + ''")"  "270"
assert "layer 4 Y = 360"  "$(ev "_LG.getMesh('B3').mesh.position.y + ''")"  "360"
assert "layer 5 Y = 450"  "$(ev "_LG.getMesh('r-arch').mesh.position.y + ''")"  "450"

# planeMeshes exist for all 6 layers
for lid in root surface category command bugs refs; do
  assert "planeMesh exists: $lid"  "$(ev "_LG.planeMeshes['$lid'] ? 'ok' : 'missing'")"  "ok"
done

# ── T3: Default visibility state ─────────────────────────────────────────────
suite "T3 — Default visibility state"

# All layers visible
for lid in root surface category command bugs refs; do
  assert "layerVisible[$lid] = true"  "$(ev "_LG.layerVisible['$lid'] + ''")"  "true"
done

# All node meshes visible
assert "all meshes visible by default"  \
  "$(ev "_LG.meshes.filter(function(m){return !m.mesh.visible}).length + ''")"  "0"

# All plane meshes visible
for lid in root surface category command bugs refs; do
  assert "planeMesh visible: $lid"  "$(ev "_LG.planeMeshes['$lid'].visible + ''")"  "true"
done

# ── T4: Default label state ───────────────────────────────────────────────────
suite "T4 — Default label state"

assert "allLabels = false"              "$(ev "_LG.allLabels + ''")"  "false"
assert "layerLabels.root = true"        "$(ev "_LG.layerLabels['root'] + ''")"  "true"
assert "layerLabels.surface = true"     "$(ev "_LG.layerLabels['surface'] + ''")"  "true"
assert "layerLabels.category = true"    "$(ev "_LG.layerLabels['category'] + ''")"  "true"
assert "layerLabels.command = false"    "$(ev "_LG.layerLabels['command'] + ''")"  "false"
assert "layerLabels.bugs = false"       "$(ev "_LG.layerLabels['bugs'] + ''")"  "false"
assert "layerLabels.refs = false"       "$(ev "_LG.layerLabels['refs'] + ''")"  "false"

# Root label visible (layerLabels.root = true)
assert "root labelObj.visible = true"  "$(ev "_LG.getMesh('vibium').labelObj.visible + ''")"  "true"
# Surface label visible
assert "cli labelObj.visible = true"   "$(ev "_LG.getMesh('cli').labelObj.visible + ''")"  "true"
# Category label visible
assert "cat-browser labelObj.visible = true"  "$(ev "_LG.getMesh('cat-browser').labelObj.visible + ''")"  "true"
# Command label hidden
assert "cmd-click labelObj.visible = false"   "$(ev "_LG.getMesh('cmd-click').labelObj.visible + ''")"  "false"
# Bug label hidden
assert "B3 labelObj.visible = false"          "$(ev "_LG.getMesh('B3').labelObj.visible + ''")"  "false"
# Fixed bug label hidden
assert "B1 labelObj.visible = false"          "$(ev "_LG.getMesh('B1').labelObj.visible + ''")"  "false"

# ── T5: Layer toggle — checkbox ───────────────────────────────────────────────
suite "T5 — Layer toggle (checkbox)"

layer_toggle_test() {
  local lid="$1" sample_node="$2"
  # Turn off
  ev "document.querySelector('[data-layer=\"$lid\"]').click()" > /dev/null
  assert "$lid off — layerVisible = false"     "$(ev "_LG.layerVisible['$lid'] + ''")"  "false"
  assert "$lid off — planeMesh hidden"         "$(ev "_LG.planeMeshes['$lid'].visible + ''")"  "false"
  assert "$lid off — sample node hidden"       "$(ev "_LG.getMesh('$sample_node').mesh.visible + ''")"  "false"
  # Turn back on
  ev "document.querySelector('[data-layer=\"$lid\"]').click()" > /dev/null
  assert "$lid on — layerVisible = true"       "$(ev "_LG.layerVisible['$lid'] + ''")"  "true"
  assert "$lid on — planeMesh visible"         "$(ev "_LG.planeMeshes['$lid'].visible + ''")"  "true"
  assert "$lid on — sample node visible"       "$(ev "_LG.getMesh('$sample_node').mesh.visible + ''")"  "true"
}

layer_toggle_test "root"     "vibium"
layer_toggle_test "surface"  "cli"
layer_toggle_test "category" "cat-clock"
layer_toggle_test "command"  "cmd-fill"
layer_toggle_test "bugs"     "B3"
layer_toggle_test "refs"     "B1"

# All nodes in a layer hidden when layer toggled off
ev "document.querySelector('[data-layer=\"command\"]').click()" > /dev/null
assert "command off — all 148 cmds hidden"  \
  "$(ev "_LG.meshes.filter(function(m){return m.node.group==='command'&&m.mesh.visible}).length + ''")"  "0"
ev "document.querySelector('[data-layer=\"command\"]').click()" > /dev/null
assert "command on — all 148 cmds visible"  \
  "$(ev "_LG.meshes.filter(function(m){return m.node.group==='command'&&!m.mesh.visible}).length + ''")"  "0"

# ── T6: Label toggle — per-layer Labels button ────────────────────────────────
suite "T6 — Per-layer Labels button"

label_btn_test() {
  local lid="$1" sample_node="$2" initial="$3"
  local btn_sel="[data-layer-lbl=\"$lid\"]"
  # If initially on, click to turn off first
  if [[ "$initial" == "on" ]]; then
    assert "$lid labels initially on — labelObj visible"  "$(ev "_LG.getMesh('$sample_node').labelObj.visible + ''")"  "true"
    ev "document.querySelector('$btn_sel').click()" > /dev/null
    assert "$lid labels off — layerLabels false"          "$(ev "_LG.layerLabels['$lid'] + ''")"  "false"
    assert "$lid labels off — labelObj hidden"            "$(ev "_LG.getMesh('$sample_node').labelObj.visible + ''")"  "false"
    ev "document.querySelector('$btn_sel').click()" > /dev/null
    assert "$lid labels on — layerLabels true"            "$(ev "_LG.layerLabels['$lid'] + ''")"  "true"
    assert "$lid labels on — labelObj visible"            "$(ev "_LG.getMesh('$sample_node').labelObj.visible + ''")"  "true"
  else
    assert "$lid labels initially off — labelObj hidden"  "$(ev "_LG.getMesh('$sample_node').labelObj.visible + ''")"  "false"
    ev "document.querySelector('$btn_sel').click()" > /dev/null
    assert "$lid labels on — layerLabels true"            "$(ev "_LG.layerLabels['$lid'] + ''")"  "true"
    assert "$lid labels on — labelObj visible"            "$(ev "_LG.getMesh('$sample_node').labelObj.visible + ''")"  "true"
    ev "document.querySelector('$btn_sel').click()" > /dev/null
    assert "$lid labels off — layerLabels false"          "$(ev "_LG.layerLabels['$lid'] + ''")"  "false"
    assert "$lid labels off — labelObj hidden"            "$(ev "_LG.getMesh('$sample_node').labelObj.visible + ''")"  "false"
  fi
}

label_btn_test "root"     "vibium"      "on"
label_btn_test "surface"  "mcp"         "on"
label_btn_test "category" "cat-dialog"  "on"
label_btn_test "command"  "cmd-hover"   "off"
label_btn_test "bugs"     "MCP-151"     "off"
label_btn_test "refs"     "r-bidi"      "off"

# ── T7: All Node Labels checkbox ─────────────────────────────────────────────
suite "T7 — All Node Labels checkbox"

assert "default allLabels = false"  "$(ev "_LG.allLabels + ''")"  "false"

# Check All Node Labels
ev "document.getElementById('all-labels').click()" > /dev/null
assert "all-labels on — allLabels = true"  "$(ev "_LG.allLabels + ''")"  "true"
assert "all-labels on — cmd-click labelObj visible"  "$(ev "_LG.getMesh('cmd-click').labelObj.visible + ''")"  "true"
assert "all-labels on — B3 labelObj visible"         "$(ev "_LG.getMesh('B3').labelObj.visible + ''")"  "true"
assert "all-labels on — r-arch labelObj visible"     "$(ev "_LG.getMesh('r-arch').labelObj.visible + ''")"  "true"
assert "all-labels on — all 230 labelObjs visible"   \
  "$(ev "_LG.meshes.filter(function(m){return !m.labelObj.visible}).length + ''")"  "0"

# Uncheck
ev "document.getElementById('all-labels').click()" > /dev/null
assert "all-labels off — allLabels = false"           "$(ev "_LG.allLabels + ''")"  "false"
assert "all-labels off — cmd-click labelObj hidden"   "$(ev "_LG.getMesh('cmd-click').labelObj.visible + ''")"  "false"
assert "all-labels off — root labelObj visible (layerLabels.root=true)"  \
  "$(ev "_LG.getMesh('vibium').labelObj.visible + ''")"  "true"

# ── T8: selectNode / deselectAll ─────────────────────────────────────────────
suite "T8 — selectNode / deselectAll"

info_visible() { ev "document.getElementById('info-panel').style.display === 'block' ? 'ok' : document.getElementById('info-panel').style.display"; }
info_content() { ev "document.getElementById('info-content').innerHTML.trim().length > 0 ? 'ok' : 'empty'"; }

# Root node
sel "vibium" > /dev/null
assert "root — info-panel visible"            "$(info_visible)"  "ok"
assert "root — info content non-empty"        "$(info_content)"  "ok"
assert "root — content has 'Vibium'"          "$(ev "document.getElementById('info-content').innerHTML.includes('Vibium') ? 'ok' : 'no'")"  "ok"
assert "root — selected mesh emissive > 0"    "$(ev "_LG.getMesh('vibium').mesh.material.emissiveIntensity > 0 ? 'ok' : '0'")"  "ok"
desel > /dev/null
assert "desel root — info-panel hidden"       "$(ev "document.getElementById('info-panel').style.display")"  "none"
assert "desel root — emissive reset"          "$(ev "_LG.getMesh('vibium').mesh.material.emissiveIntensity > 0 ? 'still-set' : 'ok'")"  "ok"

# Surface nodes
for sid in cli mcp js python java; do
  sel "$sid" > /dev/null
  assert "surface $sid — info visible"        "$(info_visible)"  "ok"
  assert "surface $sid — content non-empty"   "$(info_content)"  "ok"
  desel > /dev/null
  assert "surface $sid — desel: panel hidden" "$(ev "document.getElementById('info-panel').style.display")"  "none"
done

# Category node
sel "cat-interaction" > /dev/null
assert "category — info visible"     "$(info_visible)"  "ok"
assert "category — content has node-type"  \
  "$(ev "document.getElementById('info-content').innerHTML.includes('category') ? 'ok' : 'no'")"  "ok"
desel > /dev/null

# Command node — check surface syntax rows
sel "cmd-click" > /dev/null
assert "cmd-click — info visible"    "$(info_visible)"  "ok"
assert "cmd-click — content non-empty"  "$(info_content)"  "ok"
assert "cmd-click — has CLI row"     "$(ev "document.getElementById('info-content').innerHTML.includes('CLI') ? 'ok' : 'no'")"  "ok"
assert "cmd-click — has MCP row"     "$(ev "document.getElementById('info-content').innerHTML.includes('MCP') ? 'ok' : 'no'")"  "ok"
assert "cmd-click — has JS row"      "$(ev "document.getElementById('info-content').innerHTML.includes('JS') ? 'ok' : 'no'")"  "ok"
assert "cmd-click — has Python row"  "$(ev "document.getElementById('info-content').innerHTML.includes('Python') ? 'ok' : 'no'")"  "ok"
assert "cmd-click — has Java row"    "$(ev "document.getElementById('info-content').innerHTML.includes('Java') ? 'ok' : 'no'")"  "ok"
desel > /dev/null

# Bug node with workaround
sel "B3" > /dev/null
assert "B3 — info visible"           "$(info_visible)"  "ok"
assert "B3 — content has desc"       "$(ev "document.getElementById('info-content').innerHTML.includes('deadlock') ? 'ok' : 'no'")"  "ok"
assert "B3 — workaround rendered"    "$(ev "document.getElementById('info-content').innerHTML.includes('workaround') || document.getElementById('info-content').innerHTML.includes('vibium eval') ? 'ok' : 'no'")"  "ok"
desel > /dev/null

# Pattern node
sel "p-dialog" > /dev/null
assert "pattern — info visible"      "$(info_visible)"  "ok"
assert "pattern — content non-empty" "$(info_content)"  "ok"
desel > /dev/null

# Fixed bug node
sel "B1" > /dev/null
assert "fixed bug B1 — info visible"    "$(info_visible)"  "ok"
assert "fixed bug B1 — content has B1"  "$(ev "document.getElementById('info-content').innerHTML.includes('B1') ? 'ok' : 'no'")"  "ok"
desel > /dev/null

# Reference node
sel "r-arch" > /dev/null
assert "reference r-arch — info visible"           "$(info_visible)"  "ok"
assert "reference r-arch — content has Architecture"  \
  "$(ev "document.getElementById('info-content').innerHTML.includes('Architecture') ? 'ok' : 'no'")"  "ok"
desel > /dev/null

# ── T9: Batch — all nodes selectable ─────────────────────────────────────────
suite "T9 — Batch: all nodes selectable"

batch_result=$(ev "
(function(){
  var pass=[]; var fail=[];
  _LG.meshes.forEach(function(item){
    _LG.selectNode(item);
    var panelOk = document.getElementById('info-panel').style.display === 'block';
    var contentOk = document.getElementById('info-content').innerHTML.trim().length > 0;
    if(!panelOk||!contentOk) fail.push(item.node.id);
    _LG.deselectAll();
    var hiddenOk = document.getElementById('info-panel').style.display !== 'block';
    if(!hiddenOk) fail.push(item.node.id+'(desel)');
  });
  return fail.length===0 ? 'PASS:'+_LG.meshes.length : 'FAIL:'+fail.slice(0,5).join(',');
}())
")
if [[ "$batch_result" == PASS:* ]]; then
  pass "all ${batch_result#PASS:} nodes — selectNode/deselectAll"
else
  fail "batch select/deselect" "$batch_result" "PASS:230"
fi

# ── T10: Edge integrity ───────────────────────────────────────────────────────
suite "T10 — Edge integrity"

assert "edgeLines non-empty"  "$(ev "_LG.edgeLines.length > 0 ? 'ok' : '0'")"  "ok"

# Root → surface edges exist
for sid in cli mcp js python java; do
  assert "edge root→$sid exists"  \
    "$(ev "_LG.edgeLines.some(function(l){return l.userData.fromId==='vibium'&&l.userData.toId==='$sid'}) ? 'ok' : 'no'")"  "ok"
done

# Category → command edges exist
assert "edge cat-browser→cmd-b-start exists"  \
  "$(ev "_LG.edgeLines.some(function(l){return l.userData.fromId==='cat-browser'&&l.userData.toId==='cmd-b-start'}) ? 'ok' : 'no'")"  "ok"
assert "edge cat-interaction→cmd-click exists"  \
  "$(ev "_LG.edgeLines.some(function(l){return l.userData.fromId==='cat-interaction'&&l.userData.toId==='cmd-click'}) ? 'ok' : 'no'")"  "ok"

# All edge fromId/toId resolve to known nodes
assert "all edge endpoints in nodeMap"  \
  "$(ev "(function(){var bad=_LG.edgeLines.filter(function(l){return !_LG.nodeMap[l.userData.fromId]||!_LG.nodeMap[l.userData.toId]}); return bad.length===0 ? 'ok' : 'bad:'+bad.length}())")"  "ok"

# Root → reference edges exist
for rid in r-arch r-action r-bidi r-roadmap r-ainative; do
  assert "edge root→$rid exists"  \
    "$(ev "_LG.edgeLines.some(function(l){return l.userData.fromId==='vibium'&&l.userData.toId==='$rid'}) ? 'ok' : 'no'")"  "ok"
done

# ── T11: Spacing slider ───────────────────────────────────────────────────────
suite "T11 — Spacing slider"

assert "default SPACING = 90"  "$(ev "_LG.SPACING + ''")"  "90"

# Change spacing to 120 via input event
ev "
  var sl=document.getElementById('spacing');
  sl.value=120;
  sl.dispatchEvent(new Event('input'));
  'ok'
" > /dev/null
assert "spacing 120 — SPACING updated"       "$(ev "_LG.SPACING + ''")"  "120"
assert "spacing 120 — layer 0 Y = 0"         "$(ev "_LG.getMesh('vibium').mesh.position.y + ''")"  "0"
assert "spacing 120 — layer 1 Y = 120"       "$(ev "_LG.getMesh('cli').mesh.position.y + ''")"  "120"
assert "spacing 120 — layer 3 Y = 360"       "$(ev "_LG.getMesh('cmd-click').mesh.position.y + ''")"  "360"
assert "spacing 120 — layer 5 Y = 600"       "$(ev "_LG.getMesh('r-arch').mesh.position.y + ''")"  "600"
assert "spacing 120 — plane 0 Y = 0"         "$(ev "_LG.planeMeshes['root'].position.y + ''")"  "0"
assert "spacing 120 — plane 5 Y = 600"       "$(ev "_LG.planeMeshes['refs'].position.y + ''")"  "600"

# Reset to 90
ev "
  var sl=document.getElementById('spacing');
  sl.value=90;
  sl.dispatchEvent(new Event('input'));
  'ok'
" > /dev/null
assert "reset SPACING = 90"                  "$(ev "_LG.SPACING + ''")"  "90"
assert "reset — layer 5 Y = 450"             "$(ev "_LG.getMesh('r-arch').mesh.position.y + ''")"  "450"

# ── T12: Layer ring markings ──────────────────────────────────────────────────
suite "T12 — Layer ring markings (CSS2D)"

# 6 ring label CSS2DObjects should exist in scene tagged with layerId
assert "L0 mark in scene"  "$(ev "_LG.scene.children.some(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='root'}) ? 'ok' : 'no'")"  "ok"
assert "L1 mark in scene"  "$(ev "_LG.scene.children.some(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='surface'}) ? 'ok' : 'no'")"  "ok"
assert "L2 mark in scene"  "$(ev "_LG.scene.children.some(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='category'}) ? 'ok' : 'no'")"  "ok"
assert "L3 mark in scene"  "$(ev "_LG.scene.children.some(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='command'}) ? 'ok' : 'no'")"  "ok"
assert "L4 mark in scene"  "$(ev "_LG.scene.children.some(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='bugs'}) ? 'ok' : 'no'")"  "ok"
assert "L5 mark in scene"  "$(ev "_LG.scene.children.some(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='refs'}) ? 'ok' : 'no'")"  "ok"

# Mark label text contains layer name
assert "L0 mark text has 'Root'"     "$(ev "(function(){var m=_LG.scene.children.find(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='root'}); return m&&m.element.textContent.includes('Root') ? 'ok' : 'no'}())")"  "ok"
assert "L3 mark text has 'Commands'" "$(ev "(function(){var m=_LG.scene.children.find(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='command'}); return m&&m.element.textContent.includes('Commands') ? 'ok' : 'no'}())")"  "ok"
assert "L4 mark text has 'Bugs'"     "$(ev "(function(){var m=_LG.scene.children.find(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='bugs'}); return m&&m.element.textContent.includes('Bugs') ? 'ok' : 'no'}())")"  "ok"

# Mark hidden when layer toggled off
ev "document.querySelector('[data-layer=\"command\"]').click()" > /dev/null
assert "L3 mark hidden when layer off"  \
  "$(ev "(function(){var m=_LG.scene.children.find(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='command'}); return m&&m.visible===false ? 'ok' : 'visible'}())")"  "ok"
ev "document.querySelector('[data-layer=\"command\"]').click()" > /dev/null
assert "L3 mark visible when layer on"  \
  "$(ev "(function(){var m=_LG.scene.children.find(function(c){return c.isCSS2DObject&&c.userData&&c.userData.layerId==='command'}); return m&&m.visible===true ? 'ok' : 'hidden'}())")"  "ok"

# ── T13: Info panel close button ─────────────────────────────────────────────
suite "T13 — Info panel close button"

sel "cmd-hover" > /dev/null
assert "close-btn: panel open before"   "$(info_visible)"  "ok"
ev "document.getElementById('info-close').click()" > /dev/null
assert "close-btn: panel hidden after"  "$(ev "document.getElementById('info-panel').style.display")"  "none"
assert "close-btn: emissive reset"      "$(ev "_LG.getMesh('cmd-hover').mesh.material.emissiveIntensity > 0 ? 'still-set' : 'ok'")"  "ok"

# ── T14: Node colors ──────────────────────────────────────────────────────────
suite "T14 — Node colors"

# Root = purple (#7c3aed)
assert "root node color hex"  "$(ev "_LG.nodeMap['vibium'].color")"  "#7c3aed"
# Surfaces have distinct colors
assert "cli color = #3b82f6"    "$(ev "_LG.nodeMap['cli'].color")"  "#3b82f6"
assert "python color = #22c55e" "$(ev "_LG.nodeMap['python'].color")"  "#22c55e"
assert "java color = #f97316"   "$(ev "_LG.nodeMap['java'].color")"  "#f97316"
# Fixed bugs are green
assert "B1 fixed bug color = #4ade80"  "$(ev "_LG.nodeMap['B1'].color")"  "#4ade80"
# B3 open bug is red
assert "B3 bug-open color = #dc2626"   "$(ev "_LG.nodeMap['B3'].color")"  "#dc2626"
# Pattern is purple
assert "p-dialog pattern color = #d946ef"  "$(ev "_LG.nodeMap['p-dialog'].color")"  "#d946ef"

# ── T15: UI panel DOM elements ────────────────────────────────────────────────
suite "T15 — UI panel DOM elements"

assert "layer-panel exists"    "$(ev "document.getElementById('layer-panel') ? 'ok' : 'missing'")"  "ok"
assert "info-panel exists"     "$(ev "document.getElementById('info-panel') ? 'ok' : 'missing'")"  "ok"
assert "info-close exists"     "$(ev "document.getElementById('info-close') ? 'ok' : 'missing'")"  "ok"
assert "spacing slider exists" "$(ev "document.getElementById('spacing') ? 'ok' : 'missing'")"  "ok"
assert "all-labels checkbox"   "$(ev "document.getElementById('all-labels') ? 'ok' : 'missing'")"  "ok"
assert "hide-panel span"       "$(ev "document.getElementById('hide-panel') ? 'ok' : 'missing'")"  "ok"
assert "6 layer checkboxes"    "$(ev "document.querySelectorAll('[data-layer]').length + ''")"  "6"
assert "6 layer label buttons" "$(ev "document.querySelectorAll('[data-layer-lbl]').length + ''")"  "6"

# info-panel hidden by default
assert "info-panel hidden by default"  "$(ev "document.getElementById('info-panel').style.display")"  "none"

# controls hint exists
assert "controls-hint visible"  "$(ev "document.getElementById('controls-hint') ? 'ok' : 'missing'")"  "ok"

# ── T16: Camera controls — rotate / zoom / pan ───────────────────────────────
suite "T16 — Camera controls (Rotate · Zoom · Pan)"

# Get canvas center in screen coordinates
CX=$(ev "Math.round(window.innerWidth/2)+''")
CY=$(ev "Math.round(window.innerHeight/2)+''")
# Scale drag to 40% of viewport width — stays within bounds on any screen size
DRAG_W=$(ev "Math.round(window.innerWidth * 0.4)+''")
DRAG_H=$(ev "Math.round(window.innerHeight * 0.4)+''")

reset_cam() {
  # Cancel any in-flight pointer events so OrbitControls damping stops before reset
  ev "document.querySelector('canvas').dispatchEvent(new PointerEvent('pointercancel',{pointerId:1,bubbles:true})); 'ok'" > /dev/null
  ev "_LG.resetCamera(); 'ok'" > /dev/null
  $VIB sleep 700
}

# ── Rotate (left drag) ────────────────────────────────────────────────────────
reset_cam
PX=$(ev "_LG.camera.position.x.toFixed(3)+''")
PZ=$(ev "_LG.camera.position.z.toFixed(3)+''")

$VIB mouse move "$CX" "$CY"
$VIB mouse down
$VIB mouse move "$((CX + DRAG_W))" "$CY"
$VIB mouse up
$VIB sleep 900

assert "rotate — camera.position.x changed" \
  "$(ev "Math.abs(_LG.camera.position.x - ($PX)) > 5 ? 'ok' : 'unchanged:x='+_LG.camera.position.x.toFixed(1)")"  "ok"
assert "rotate — camera.position.z changed" \
  "$(ev "Math.abs(_LG.camera.position.z - ($PZ)) > 5 ? 'ok' : 'unchanged:z='+_LG.camera.position.z.toFixed(1)")"  "ok"
assert "rotate — orbit radius preserved (500–1500)" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500 ? 'ok' : 'dist='+d.toFixed(0)}())")"  "ok"
assert "rotate — camera Y approximately preserved" \
  "$(ev "Math.abs(_LG.camera.position.y - 550) < 200 ? 'ok' : 'y='+_LG.camera.position.y.toFixed(0)")"  "ok"

# ── Zoom in (wheel) ───────────────────────────────────────────────────────────
reset_cam
D0=$(ev "_LG.dist().toFixed(3)+''")

ev "document.querySelector('canvas').dispatchEvent(new WheelEvent('wheel',{deltaY:-400,bubbles:true,cancelable:true}))" > /dev/null
$VIB sleep 700

assert "zoom in — distance decreased" \
  "$(ev "_LG.dist() < $D0 ? 'ok' : 'dist='+_LG.dist().toFixed(0)+' before=$D0'")"  "ok"
assert "zoom in — camera still above target" \
  "$(ev "_LG.camera.position.y > _LG.controls.target.y ? 'ok' : 'no'")"  "ok"

# ── Zoom out (wheel) ──────────────────────────────────────────────────────────
D1=$(ev "_LG.dist().toFixed(3)+''")

ev "document.querySelector('canvas').dispatchEvent(new WheelEvent('wheel',{deltaY:400,bubbles:true,cancelable:true}))" > /dev/null
$VIB sleep 700

assert "zoom out — distance increased" \
  "$(ev "_LG.dist() > $D1 ? 'ok' : 'dist='+_LG.dist().toFixed(0)+' before=$D1'")"  "ok"

# ── Pan (right drag) ──────────────────────────────────────────────────────────
reset_cam
TY=$(ev "_LG.controls.target.y.toFixed(3)+''")
TX=$(ev "_LG.controls.target.x.toFixed(3)+''")

$VIB mouse move "$CX" "$CY"
$VIB mouse down --button 2
$VIB mouse move "$CX" "$((CY + 180))"
$VIB mouse up --button 2
$VIB sleep 900

assert "pan — controls.target changed" \
  "$(ev "(function(){var dy=_LG.controls.target.y-($TY),dx=_LG.controls.target.x-($TX); return Math.sqrt(dx*dx+dy*dy)>2?'ok':'unchanged:dy='+dy.toFixed(2)}())")"  "ok"
assert "pan — orbit radius preserved after pan" \
  "$(ev "(function(){var d=_LG.dist(); return d>400&&d<1800?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Controls hint text ────────────────────────────────────────────────────────
assert "hint text — Rotate: Drag"      "$(ev "document.getElementById('controls-hint').textContent.includes('Rotate: Drag') ? 'ok' : 'no'")"  "ok"
assert "hint text — Zoom: Scroll"      "$(ev "document.getElementById('controls-hint').textContent.includes('Zoom: Scroll') ? 'ok' : 'no'")"  "ok"
assert "hint text — Pan: Right-drag"   "$(ev "document.getElementById('controls-hint').textContent.includes('Pan: Right-drag') ? 'ok' : 'no'")"  "ok"

# ── resetCamera accuracy ──────────────────────────────────────────────────────
# Camera is panned; rotate it further so position is definitely off, then verify
# resetCamera lands within 1 unit of (0,550,900) — regression for double-update fix
$VIB mouse move "$CX" "$CY"
$VIB mouse down
$VIB mouse move "$((CX + DRAG_W))" "$CY"
$VIB mouse up
$VIB sleep 400

reset_cam

assert "resetCamera — camera at exact spawn (0,550,900) within 1 unit" \
  "$(ev "(function(){ var p=_LG.camera.position; var dx=Math.abs(p.x), dy=Math.abs(p.y-550), dz=Math.abs(p.z-900); return Math.max(dx,dy,dz)<1?'ok':'x='+p.x.toFixed(1)+' y='+p.y.toFixed(1)+' z='+p.z.toFixed(1) }())")"  "ok"

reset_cam

# ── T16b: Rotate extended ─────────────────────────────────────────────────────
suite "T16b — Rotate extended"

CANVAS_H=$(ev "window.innerHeight+''")
# For the ~180° drag: cap horizontal travel to safe range from center
HALF_H=$((CANVAS_H / 2))
HALF_H_SAFE=$(( HALF_H < (CX - 5) ? HALF_H : (CX - 5) ))

# helper: capture camera XYZ and dist as a single string "x,y,z,dist"
cam_state() { ev "(function(){var p=_LG.camera.position,d=_LG.dist(); return p.x.toFixed(2)+','+p.y.toFixed(2)+','+p.z.toFixed(2)+','+d.toFixed(2)}())"; }
tgt_state() { ev "(function(){var t=_LG.controls.target; return t.x.toFixed(2)+','+t.y.toFixed(2)+','+t.z.toFixed(2)}())"; }

# ── Direction: drag left ──────────────────────────────────────────────────────
reset_cam
# Baseline right-drag: record resulting X after dragging right
$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$((CX + DRAG_W))" "$CY"; $VIB mouse up; $VIB sleep 900
PX_RIGHT=$(ev "_LG.camera.position.x.toFixed(2)+''")

reset_cam
# Drag left same amount
$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$((CX - DRAG_W))" "$CY"; $VIB mouse up; $VIB sleep 900
PX_LEFT=$(ev "_LG.camera.position.x.toFixed(2)+''")

assert "rotate left — x changes opposite sign to rotate-right" \
  "$(ev "(function(){ var r=$PX_RIGHT, l=$PX_LEFT; return (r>0&&l<0)||(r<0&&l>0)||(Math.abs(r-l)>10) ? 'ok' : 'same:r='+r+',l='+l }())")"  "ok"
assert "rotate left — radius preserved" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Direction: drag up ────────────────────────────────────────────────────────
reset_cam
PY_BEFORE=$(ev "_LG.camera.position.y.toFixed(2)+''")
$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$CX" "$((CY - 180))"; $VIB mouse up; $VIB sleep 900
PY_UP=$(ev "_LG.camera.position.y.toFixed(2)+''")

assert "rotate up — camera.y changed" \
  "$(ev "Math.abs(_LG.camera.position.y - ($PY_BEFORE)) > 5 ? 'ok' : 'unchanged:y='+_LG.camera.position.y.toFixed(1)")"  "ok"
assert "rotate up — radius preserved" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Direction: drag down ──────────────────────────────────────────────────────
reset_cam
$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$CX" "$((CY + 180))"; $VIB mouse up; $VIB sleep 900
PY_DOWN=$(ev "_LG.camera.position.y.toFixed(2)+''")

assert "rotate down — camera.y changes opposite direction to rotate-up" \
  "$(ev "(function(){ var u=$PY_UP, d=$PY_DOWN; return (u>($PY_BEFORE)&&d<($PY_BEFORE))||(u<($PY_BEFORE)&&d>($PY_BEFORE)) ? 'ok' : 'up='+u+',down='+d+',before=$PY_BEFORE' }())")"  "ok"
assert "rotate down — radius preserved" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Direction: diagonal drag ──────────────────────────────────────────────────
reset_cam
PX_D=$(ev "_LG.camera.position.x.toFixed(2)+''")
PY_D=$(ev "_LG.camera.position.y.toFixed(2)+''")
$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$((CX + 180))" "$((CY - 120))"; $VIB mouse up; $VIB sleep 900

assert "rotate diagonal — camera.x changed" \
  "$(ev "Math.abs(_LG.camera.position.x - ($PX_D)) > 5 ? 'ok' : 'unchanged'")"  "ok"
assert "rotate diagonal — camera.y changed" \
  "$(ev "Math.abs(_LG.camera.position.y - ($PY_D)) > 5 ? 'ok' : 'unchanged'")"  "ok"
assert "rotate diagonal — radius preserved" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Target stability: rotation never moves controls.target ────────────────────
reset_cam
TX0=$(ev "_LG.controls.target.x.toFixed(2)+''")
TY0=$(ev "_LG.controls.target.y.toFixed(2)+''")
TZ0=$(ev "_LG.controls.target.z.toFixed(2)+''")

# four rotations without reset
for DRAG_X_OFFSET in 180 -160 100 -80; do
  $VIB mouse move "$CX" "$CY"; $VIB mouse down
  $VIB mouse move "$((CX + DRAG_X_OFFSET))" "$CY"; $VIB mouse up; $VIB sleep 600
done

assert "target stability — target.x fixed through 4 rotations" \
  "$(ev "Math.abs(_LG.controls.target.x - ($TX0)) < 2 ? 'ok' : 'drift='+(_LG.controls.target.x-($TX0)).toFixed(2)")"  "ok"
assert "target stability — target.y fixed through 4 rotations" \
  "$(ev "Math.abs(_LG.controls.target.y - ($TY0)) < 2 ? 'ok' : 'drift='+(_LG.controls.target.y-($TY0)).toFixed(2)")"  "ok"
assert "target stability — target.z fixed through 4 rotations" \
  "$(ev "Math.abs(_LG.controls.target.z - ($TZ0)) < 2 ? 'ok' : 'drift='+(_LG.controls.target.z-($TZ0)).toFixed(2)")"  "ok"

# ── Radius invariance across 5 different random-ish rotations ─────────────────
reset_cam
R_INIT=$(ev "_LG.dist().toFixed(2)+''")

for COMBO in "120 -80" "-90 60" "$DRAG_W 0" "0 -150" "-140 90"; do
  DX=$(echo $COMBO | cut -d' ' -f1)
  DY=$(echo $COMBO | cut -d' ' -f2)
  $VIB mouse move "$CX" "$CY"; $VIB mouse down
  $VIB mouse move "$((CX + DX))" "$((CY + DY))"; $VIB mouse up; $VIB sleep 650
  assert "radius invariant after drag ($DX,$DY)" \
    "$(ev "(function(){var d=_LG.dist(),r=$R_INIT; return Math.abs(d-r)/r < 0.05 ? 'ok' : 'drift='+((d-r)/r*100).toFixed(1)+'%'}())")"  "ok"
done

# ── Reversal: rotate right then back left same amount → approximately same pos ─
reset_cam
PX_S=$(ev "_LG.camera.position.x.toFixed(2)+''")
PZ_S=$(ev "_LG.camera.position.z.toFixed(2)+''")

$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$((CX + 180))" "$CY"; $VIB mouse up; $VIB sleep 900

$VIB mouse move "$((CX + 180))" "$CY"; $VIB mouse down
$VIB mouse move "$CX" "$CY"; $VIB mouse up; $VIB sleep 1200

assert "rotate-right-then-left — x returns within 25 units" \
  "$(ev "Math.abs(_LG.camera.position.x - ($PX_S)) < 25 ? 'ok' : 'diff='+Math.abs(_LG.camera.position.x-($PX_S)).toFixed(1)")"  "ok"
assert "rotate-right-then-left — z returns within 25 units" \
  "$(ev "Math.abs(_LG.camera.position.z - ($PZ_S)) < 25 ? 'ok' : 'diff='+Math.abs(_LG.camera.position.z-($PZ_S)).toFixed(1)")"  "ok"
assert "rotate-right-then-left — radius preserved" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Large rotation (~180°): drag half canvas-height → ~π radians ─────────────
reset_cam
PZ_INIT=$(ev "_LG.camera.position.z.toFixed(2)+''")  # should be ~900

$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$((CX + HALF_H_SAFE))" "$CY"; $VIB mouse up; $VIB sleep 1200

assert "rotate ~180° — Z changes sign (flips from +900 to ~-900)" \
  "$(ev "(function(){ var z=$PZ_INIT, nz=_LG.camera.position.z; return z>0&&nz<0?'ok':'z='+nz.toFixed(0) }())")"  "ok"
assert "rotate ~180° — radius preserved" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Polar angle clamping: drag far down → phi decreases toward 0 (north pole) ─
# dragging mouse DOWN → phiDelta negative → phi decreases → camera orbits upward
# clamp at minPolarAngle(0) keeps camera above north pole; camera.y > target.y
reset_cam
$VIB mouse move "$CX" "$CY"; $VIB mouse down
$VIB mouse move "$CX" "$((CANVAS_H - 1))"; $VIB mouse up; $VIB sleep 1000

assert "polar clamp — camera.y > target.y after far downward drag" \
  "$(ev "_LG.camera.position.y > _LG.controls.target.y ? 'ok' : 'below'")"  "ok"
assert "polar clamp — radius preserved despite clamp" \
  "$(ev "(function(){var d=_LG.dist(); return d>500&&d<1500?'ok':'dist='+d.toFixed(0)}())")"  "ok"

# ── Smooth 360° twirl: one continuous drag, 36 intermediate moves ─────────────
# Single pointerdown session with 36 pointermove events spaced STEP_PX apart.
# Total drag ≈ CANVAS_H → 360°. Continuous drag = no per-step damping
# accumulation, so camera returns cleanly to start position.
TWIRL_START=10
TWIRL_END=$(( CX * 2 - 10 ))
TWIRL_STEP=$(( (TWIRL_END - TWIRL_START) / 36 ))

reset_cam
PX_1T=$(ev "_LG.camera.position.x.toFixed(2)+''")
PY_1T=$(ev "_LG.camera.position.y.toFixed(2)+''")
PZ_1T=$(ev "_LG.camera.position.z.toFixed(2)+''")
R_1T=$(ev "_LG.dist().toFixed(2)+''")

$VIB mouse move "$TWIRL_START" "$CY"; $VIB mouse down
for STEP in $(seq 36); do
  $VIB mouse move "$((TWIRL_START + STEP * TWIRL_STEP))" "$CY"
done
$VIB mouse up; $VIB sleep 1200

assert "1× twirl 360° — angular return within 15°" \
  "$(ev "(function(){var sx=$PX_1T,sz=$PZ_1T,ex=_LG.camera.position.x,ez=_LG.camera.position.z; var cosA=(sx*ex+sz*ez)/(Math.sqrt(sx*sx+sz*sz)*Math.sqrt(ex*ex+ez*ez)); var a=Math.acos(Math.max(-1,Math.min(1,cosA)))*180/Math.PI; return a<15?'ok':'deg='+a.toFixed(1)}())")"  "ok"
assert "1× twirl 360° — y no vertical drift (< 10)" \
  "$(ev "Math.abs(_LG.camera.position.y - ($PY_1T)) < 10 ? 'ok' : 'drift='+Math.abs(_LG.camera.position.y-($PY_1T)).toFixed(1)")"  "ok"
assert "1× twirl 360° — radius preserved < 5%" \
  "$(ev "(function(){var d=_LG.dist(),r=$R_1T; return Math.abs(d-r)/r<0.05?'ok':'err='+((d-r)/r*100).toFixed(1)+'%'}())")"  "ok"
assert "1× twirl 360° — target unchanged" \
  "$(ev "Math.abs(_LG.controls.target.y - ($TY0)) < 2 ? 'ok' : 'drift='+(_LG.controls.target.y-($TY0)).toFixed(2)")"  "ok"

# ── Smooth 720° twirl: two consecutive full-width drags = 2 full orbits ───────
reset_cam
PX_2T=$(ev "_LG.camera.position.x.toFixed(2)+''")
PY_2T=$(ev "_LG.camera.position.y.toFixed(2)+''")
PZ_2T=$(ev "_LG.camera.position.z.toFixed(2)+''")
R_2T=$(ev "_LG.dist().toFixed(2)+''")

for ORBIT in 1 2; do
  $VIB mouse move "$TWIRL_START" "$CY"; $VIB mouse down
  for STEP in $(seq 36); do
    $VIB mouse move "$((TWIRL_START + STEP * TWIRL_STEP))" "$CY"
  done
  $VIB mouse up
done
$VIB sleep 1500

assert "2× twirl 720° — angular return within 25°" \
  "$(ev "(function(){var sx=$PX_2T,sz=$PZ_2T,ex=_LG.camera.position.x,ez=_LG.camera.position.z; var cosA=(sx*ex+sz*ez)/(Math.sqrt(sx*sx+sz*sz)*Math.sqrt(ex*ex+ez*ez)); var a=Math.acos(Math.max(-1,Math.min(1,cosA)))*180/Math.PI; return a<25?'ok':'deg='+a.toFixed(1)}())")"  "ok"
assert "2× twirl 720° — z drift within viewport-scaled tolerance" \
  "$(ev "(function(){ var drift=Math.abs(_LG.camera.position.z-($PZ_2T)); var stepPx=Math.floor(($TWIRL_END-$TWIRL_START)/36); var orbitDeg=2*stepPx*36*360/window.innerWidth; var shortfall=720-orbitDeg; var tol=Math.max(60,Math.abs(900*Math.cos(shortfall*Math.PI/180)-900)+30); return drift<tol?'ok':'diff='+drift.toFixed(1)+' tol='+tol.toFixed(0) }())")"  "ok"
assert "2× twirl 720° — y no vertical drift (< 15)" \
  "$(ev "Math.abs(_LG.camera.position.y - ($PY_2T)) < 15 ? 'ok' : 'drift='+Math.abs(_LG.camera.position.y-($PY_2T)).toFixed(1)")"  "ok"
assert "2× twirl 720° — radius preserved < 5%" \
  "$(ev "(function(){var d=_LG.dist(),r=$R_2T; return Math.abs(d-r)/r<0.05?'ok':'err='+((d-r)/r*100).toFixed(1)+'%'}())")"  "ok"
assert "2× twirl 720° — radius matches 1× twirl baseline" \
  "$(ev "(function(){var d=_LG.dist(),r=$R_1T; return Math.abs(d-r)/r<0.05?'ok':'drift='+((d-r)/r*100).toFixed(1)+'%'}())")"  "ok"

reset_cam

# ── T17: Layer spacing slider drag ────────────────────────────────────────────
suite "T17 — Layer spacing slider"

# Panel auto-collapses on mobile — expand it so the slider is interactable
ev "
  var first = document.querySelector('#layer-panel > *:not(h4)');
  if (first && first.style.display === 'none') document.getElementById('hide-panel').click();
  'ok'
" > /dev/null
$VIB sleep 200

# Initial state already tested in T11 — here test via actual slider drag
# Get slider position
SL_RECT=$(ev "JSON.stringify(document.getElementById('spacing').getBoundingClientRect())")
SL_CX=$(ev "Math.round(document.getElementById('spacing').getBoundingClientRect().left + document.getElementById('spacing').getBoundingClientRect().width/2)+''")
SL_CY=$(ev "Math.round(document.getElementById('spacing').getBoundingClientRect().top + document.getElementById('spacing').getBoundingClientRect().height/2)+''")
SL_RIGHT=$(ev "Math.round(document.getElementById('spacing').getBoundingClientRect().right)+''")
SL_LEFT=$(ev "Math.round(document.getElementById('spacing').getBoundingClientRect().left)+''")

assert "spacing slider — min=40"   "$(ev "document.getElementById('spacing').min+''")"  "40"
assert "spacing slider — max=180"  "$(ev "document.getElementById('spacing').max+''")"  "180"
assert "spacing slider — default=90" "$(ev "document.getElementById('spacing').value+''")"  "90"

# Drag slider to far right → max value
$VIB mouse move "$SL_CX" "$SL_CY"
$VIB mouse down
$VIB mouse move "$SL_RIGHT" "$SL_CY"
$VIB mouse up
$VIB sleep 300

SP_HIGH=$(ev "_LG.SPACING+''")
assert "slider drag right — SPACING increased above 90" \
  "$(ev "_LG.SPACING > 90 ? 'ok' : 'spacing='+_LG.SPACING")"  "ok"
assert "slider drag right — layer 5 Y = 5×SPACING" \
  "$(ev "Math.abs(_LG.getMesh('r-arch').mesh.position.y - 5*_LG.SPACING) < 0.1 ? 'ok' : 'mismatch'")"  "ok"
assert "slider drag right — edges rebuild (layer 1 edge Y matches)" \
  "$(ev "(function(){var e=_LG.edgeLines.find(function(l){return l.userData.fromId==='vibium'&&l.userData.toId==='cli'}); if(!e)return 'no-edge'; var pos=e.geometry.attributes.position; var y1=pos.getY(1); return Math.abs(y1-_LG.SPACING)<0.5?'ok':'y1='+y1.toFixed(1)+' sp='+_LG.SPACING}())")"  "ok"

# Drag slider to far left → min value
$VIB mouse move "$SL_CX" "$SL_CY"
$VIB mouse down
$VIB mouse move "$SL_LEFT" "$SL_CY"
$VIB mouse up
$VIB sleep 300

assert "slider drag left — SPACING decreased below 90" \
  "$(ev "_LG.SPACING < 90 ? 'ok' : 'spacing='+_LG.SPACING")"  "ok"
assert "slider drag left — layer 5 Y = 5×SPACING" \
  "$(ev "Math.abs(_LG.getMesh('r-arch').mesh.position.y - 5*_LG.SPACING) < 0.1 ? 'ok' : 'mismatch'")"  "ok"

# Reset to 90
ev "var sl=document.getElementById('spacing'); sl.value=90; sl.dispatchEvent(new Event('input')); 'ok'" > /dev/null

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

HISTORY_FILE="$(dirname "$0")/run-history.log"
echo "$RUN_TS  [layered] $PASS / $TOTAL passed  ($FAIL failed)  → runs/layered-$RUN_TS.txt" >> "$HISTORY_FILE"
echo "Saved → $RUN_LOG"

$VIB daemon stop 2>/dev/null || true

[[ $FAIL -eq 0 ]] && exit 0 || exit 1
