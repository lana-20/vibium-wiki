# Roadmap

Source: `ROADMAP.md` · Status: future / not yet implemented

Future features — not yet prioritized. Revisit based on user feedback.

---

## Vision: Sense → Think → Act

| Layer | Component | Purpose | Status |
|---|---|---|---|
| **Sense** | Retina | Chrome extension that observes everything | deferred |
| **Think** | Cortex | Memory + navigation planning | deferred |
| **Act** | Vibium | Browser automation via BiDi | ✅ shipped |

---

## Cortex — Think Layer

**What:** SQLite-backed datastore that builds an "app map" of the application — graph of pages, actions, sessions.

**Capabilities when built:**
- sqlite-vec embeddings for semantic search
- REST API for data ingestion (JSONL)
- MCP tools: `page_info`, `find_element`, `find_path`, `search`, `history`
- Graph builder + Dijkstra pathfinding

**When to build:** When users report agents repeatedly rediscovering flows, losing cross-session context, or unable to plan multi-step navigation.

**Estimated effort:** 2-3 weeks. Prototype visualization: `vibium-cortex.lovable.app/?dataset=view-action-sample`

---

## Retina — Sense Layer

**What:** Chrome Manifest V3 extension that passively records all browser activity regardless of what's driving it.

**Capabilities when built:**
- Content script: click, keypress, navigation listeners
- DOM snapshot + screenshot capture
- JSONL formatting + Cortex sender
- Popup UI for recording control

**When to build:** When users need to record human sessions for replay, debug agent runs, or train models on interaction data. Depends on Cortex existing.

**Estimated effort:** 1-2 weeks.

---

## AI-Powered Locators

**What:** Natural language element finding and actions.

```typescript
await vibe.do("click the login button");
await vibe.check("verify the dashboard loaded");
const el = await vibe.find("the blue submit button");
```

**Why deferred:** Vision model integration raises unresolved questions: local (Qwen-VL) vs API (Claude vision), latency, cost, ambiguity handling, caching.

See → [[reference/ai-native]] for full spec of `page.check()` and `page.do()`.

**Estimated effort:** 3-6 weeks (high uncertainty).

---

## Video Recording

**What:** Built-in screen recording via FFmpeg.

**API shape:**
```javascript
await vibe.startRecording();
await vibe.stopRecording(); // → Buffer (MP4/WebM)
```

**When to build:** When users need video artifacts for test failure debugging, demo generation, or audit trails.

**Estimated effort:** 1 week. Blocked on FFmpeg dependency.

---

## .NET Client

**What:** Official NuGet package with idiomatic C# API.

**Status:** Community implementation exists at `github.com/webdriverbidi-net/vibium-net` (by @jimevans). Not yet officially supported.

---

## Additional Browsers

**What:** Firefox, Edge, Safari, Brave support.

**When to build:** When users explicitly request. BiDi implementations vary. Chrome covers 90%+ of use cases.

**Estimated effort:** 1 week per browser.

---

## Docker & Cloud

**What:** Official Docker images + Fly.io deployment guides.

**When to build:** When users want to run agents in CI or production.

**Estimated effort:** 1 week.

---

## Priority order (tentative)

1. More browsers
2. Video recording
3. Retina (if recording human sessions matters)
4. Cortex (if agents need persistent memory)
5. AI locators (high value, high uncertainty)
6. Cortex UI (nice to have)

→ [[reference/ai-native]]
