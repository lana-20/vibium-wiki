# Python Client Bug Index

Last updated: 2026-06-14 · reference version: v26.5.31

## Open issues

| Issue | Title | Status |
|---|---|---|
| #146 | capture.dialog(fn) deadlocks when fn calls page.evaluate("alert(...)") | open |

## Fixed in v26.5.31 (closed 2026-05-31)

| Issue | Title | Notes |
|---|---|---|
| #168 | page.screenshot(full_page=True) overflows asyncio 64KB readline buffer on large PNGs | fixed |
| #147 | element.bounds() returns BoundingBox dataclass, not dict — dict operations raise TypeError | fixed |
| #145 | page.wait_until() requires full function expression — bare JS expressions always time out | fixed |
| #144 | page.eval() alias does not exist on Page | fixed |
| #110 | Python client can crash on large pipe messages with asyncio.LimitOverrunError (e.g. screenshot) | fixed |
| #94 | Python: type definitions are unstructured Dict[str, Any] | fixed |
| #93 | Python: sync __init__.py only exports 5 of ~15 public types | fixed |
| #92 | Python: missing error types (JS has 4, Python has 2) | fixed |
| #91 | Python: emulate_media() leaks camelCase kwargs to Python users | fixed |

## Detail: #146 — capture.dialog deadlock (open)

**Trigger:** Inside `capture.dialog(fn)`, calling `page.evaluate("alert(...)")` (or triggering a native dialog via evaluate) deadlocks the session. The capture handler waits for the fn to complete, but fn is blocked waiting for the dialog to be dismissed, which can't happen until capture.dialog resolves — circular.

**Also affects:** Any code path where `fn` inside `capture.dialog` awaits a call that triggers a native dialog before returning.

**Workaround:** use `page.evaluate("setTimeout(() => alert('msg'), 300)")` — the evaluate returns before the dialog fires.

**Same root cause as:** B3 (CLI), #151 (MCP), #142 (recording mode), #128 (Java route/setHeaders).

→ [[patterns/dialog_deadlock]]

## Detail: #168 — screenshot asyncio buffer (fixed v26.5.31)

Large PNG payloads (full-page screenshots of long pages) overflowed the asyncio `readline` 64KB buffer. The fix raised the buffer limit. Related to #110 (same asyncio.LimitOverrunError on large pipe messages).

## Notes on the vibium-python-test suite

Python API regression suite: 140 tests at `~/vibium-python-test/test_vibium_python.py`.
Last run: v26.5.31. See project memory for run status.
