---
method: select
aliases: [browser_select]
last_tested: v26.5.31
last_tested_date: 2026-06-01
bugs: [B5]
status: partial
---

# select / browser_select

Selects an option in a `<select>` element by visible label or value.

## v26.5.31 changes (B5 · partial fix · #140)

Two behaviors changed:

1. **Now matches by visible label** (previously matched only `value` attribute). `vibium select "#sel" "Yellow"` now finds the option whose displayed text is "Yellow".

2. **Now errors on non-matching option** (previously returned exit 0 with no selection — silent false success). Selecting a nonexistent option now returns exit 1.

⚠️ **Breaking:** code that relied on the silent no-op will now see an error.

## Remaining open issue (B5 · partial)

The "silent false success" path — selecting a nonexistent option — is now partially fixed (exits 1). But verify across all select types: some edge cases may still silently accept invalid values on certain element implementations.

## Site-specific notes

### Parking Cost Calculator (shino.de/parkcalc)

Display text ≠ `value` attribute on this site:

| Display text | value attribute |
|---|---|
| "Valet Parking" | "Valet" |
| "Short-Term Parking" | "Short" |
| "Economy Parking" | "Economy" |

As of v26.5.31, `vibium select "#ParkingLot" "Short-Term Parking"` should work (label matching). Verify if it selects correctly and `.value` reflects the expected `"Short"`.

Previously, only `vibium select "#ParkingLot" "Short"` (value attribute) worked.

## Workaround (pre-v26.5.31 or fallback)

```sh
# Select by value attribute via eval
vibium eval 'document.querySelector("#sel").value = "Short"; document.querySelector("#sel").dispatchEvent(new Event("change", {bubbles:true}))'
```

## Related

→ [[bugs/cli#B5]]
