# Recording

Source: `docs/explanation/recording-format.md`

---

## What it captures

A recording captures a timeline of: screenshots, network requests, DOM snapshots, and action groups — packaged into a single zip file.

Compatible with [player.vibium.dev](https://player.vibium.dev) and the standard [Playwright trace viewer](https://trace.playwright.dev).

---

## CLI usage

```bash
vibium record start          # start recording with screenshots
vibium record start --chunk  # start a new chunk
vibium record stop           # stop and save to record.zip
vibium record stop --chunk   # stop chunk, save chunk zip
```

## JS API

```javascript
const rec = await vibe.record.start({ title: 'login flow' })
// ... do stuff ...
const zip = await rec.stop()               // returns Buffer (zip)
await fs.writeFile('record.zip', zip)
```

---

## Zip structure

```
record.zip
├── trace.trace             # Main event timeline (newline-delimited JSON)
├── trace.network           # Network events (newline-delimited JSON)
└── resources/
    ├── page@abc123-1773879004791.jpeg
    └── page@abc123-1773879004850.jpeg
```

For chunked recordings: first chunk uses `trace.trace` / `trace.network`, subsequent chunks use `1.trace` / `1.network`, etc.

---

## Timestamps

All timestamps are **relative monotonic milliseconds** since recording start (small values like `0`, `500`, `3200`).

Exception: `wallTime` on `context-options` and `frame-snapshot` events is absolute Unix ms (for calendar time reference only).

---

## Event types

### `context-options` — first event in every trace

```json
{"version":8,"type":"context-options","libraryName":"vibium","libraryVersion":"26.3.18","browserName":"chromium","platform":"darwin","wallTime":1708000000000,"monotonicTime":0,...}
```

### `screencast-frame` — screenshot

```json
{"type":"screencast-frame","pageId":"page@abc","sha1":"page@abc-1773879004791.jpeg","width":1280,"height":720,"timestamp":100}
```

### `before` / `after` — action brackets

Every Vibium command emits a `before` + `after` pair automatically. Format: `call@N` (shared monotonic counter).

```json
{"type":"before","callId":"call@2","startTime":500,"class":"Element","method":"vibium:element.click","pageId":"page@abc","params":{"selector":"#btn"},"beforeSnapshot":"before@call@2","title":"Element.click"}
{"type":"input","callId":"call@2","point":{"x":640,"y":360},"box":{"x":600,"y":340,"width":80,"height":40}}
{"type":"after","callId":"call@2","endTime":600}
```

**Snapshot rules:**
- Click-like actions (`click`, `hover`, `check`): `beforeSnapshot` only
- Fill-like actions (`fill`, `type`, `selectOption`): `beforeSnapshot` + `afterSnapshot`
- Query actions (`find`, `text`, `navigate`): `afterSnapshot` only

### Action groups

Named spans via `startGroup()` / `stopGroup()`. Actions inside a group have a `parentId` field.

```json
{"type":"before","callId":"call@4","startTime":300,"class":"Tracing","method":"tracingGroup","params":{"name":"login flow"},"title":"login flow"}
{"type":"before","callId":"call@5","parentId":"call@4","startTime":350,...}
```

### `frame-snapshot` — DOM snapshot

DOM tree as nested arrays: `["TAG", {attrs}, ...children]`. Captured before/after interactions.

### `resource-snapshot` (in `.network`) — HAR entry

One line per network request. HAR 1.2 format with extra `_monotonicTime` (relative ms) and `_frameref` (page ID).

---

## Chunks

```
start() ──────────────────────────────────── stop()
          │                │
     stopChunk()      startChunk()
     → zip A          stopChunk()
                      → zip B
```

- Chunk timestamps reset to `0` on each `startChunk()`
- Resources (screenshots, snapshots) are shared — not cleared per chunk
- Chunk indexes: `0.trace`, `1.trace`, `2.trace`...

---

## Viewing

1. Go to [player.vibium.dev](https://player.vibium.dev)
2. Drop your `record.zip` onto the page

Shows: timeline with screenshots, individual actions, network waterfall, DOM snapshots, action groups.

With `{ bidi: true }` start option: raw BiDi commands visible as nested entries within parent actions.

---

## Known issues

- CLI: `vibium click` during recording deadlocks on POST redirect → [[bugs/cli#B3]] (#142)
- Recording mode is one of the B3/deadlock pattern variants → [[patterns/dialog_deadlock]]

→ [[methods/navigate]] · → [[bugs/cli#B3]] · → [[patterns/dialog_deadlock]]
