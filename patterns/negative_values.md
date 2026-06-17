# Pattern: Negative Values Parsed as Flags

## Summary

The Vibium CLI argument parser treats any argument beginning with `-` as a flag shorthand. This silently breaks any command that needs to pass a negative number as a value.

**Affects CLI only.** MCP tools pass values as JSON fields — not subject to this issue.

---

## Affected commands

| Command | Bug | Example failure |
|---|---|---|
| `vibium geolocation lat lon` | B14 | `vibium geolocation 37.7749 -122.4194` → `unknown shorthand flag: '1' in -122.4194` |
| `vibium fill "#sel" "-2"` | B18 | `vibium fill "input" "-2"` → `unknown shorthand flag: '2' in -2` |
| `vibium type "#sel" "-2"` | B18 | same |
| `vibium sleep -1` | B22 | `vibium sleep -1` → `unknown shorthand flag: '1' in -1` |

---

## Workarounds

### fill / type — eval native value setter

```sh
vibium eval 'const s=Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype,"value").set; const el=document.querySelector("input#first"); s.call(el,"-2"); el.dispatchEvent(new Event("input",{bubbles:true}))'
```

### geolocation — use `--` arg separator (if supported)

The POSIX `--` separator signals end of options. Vibium may or may not honor it:
```sh
vibium geolocation -- 37.7749 -122.4194
```

If `--` is not supported, use eval to set geolocation via the Geolocation API directly.

### sleep — validate before calling

Client-side validation before invoking:
```sh
DURATION="-1"
[ "$DURATION" -ge 0 ] && vibium sleep "$DURATION"
```

---

## Root cause

cobra CLI library default behavior — single-dash args are always interpreted as shorthand flags unless the command explicitly calls `Args(cobra.ArbitraryArgs)` or the value is quoted in a way that disables flag parsing.

→ [[bugs/cli#B14]] · → [[bugs/cli#B18]] · → [[bugs/cli#B22]]
