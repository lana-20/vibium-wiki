# Getting Started — JavaScript / TypeScript

Source: `docs/tutorials/getting-started-js.md`

---

## Install

```bash
mkdir my-bot && cd my-bot
npm init -y
npm install vibium
```

Chrome for Testing downloads automatically (may take a minute).

| Platform | Cache path |
|---|---|
| Linux | `~/.cache/vibium/` |
| macOS | `~/Library/Caches/vibium/` |
| Windows | `%LOCALAPPDATA%\vibium\` |

Override cache: `VIBIUM_CACHE_DIR=/path/to/dir`. Skip browser download: `VIBIUM_SKIP_BROWSER_DOWNLOAD=1`.

---

## Sync API (simplest)

```javascript
const fs = require('fs')
const { browser } = require('vibium/sync')

const bro = browser.start()
const vibe = bro.page()

vibe.go('https://example.com')
const png = vibe.screenshot()
fs.writeFileSync('screenshot.png', png)

const link = vibe.find('a')
console.log('Found link:', link.text())
link.click()

bro.stop()
```

Run: `node hello.js`

---

## Async API

```javascript
const { browser } = require('vibium')

async function main() {
  const bro = await browser.start()
  const vibe = await bro.page()
  await vibe.go('https://example.com')

  const png = await vibe.screenshot()
  require('fs').writeFileSync('screenshot.png', png)

  const link = await vibe.find('a')
  await link.click()
  await bro.stop()
}

main()
```

---

## Common options

```javascript
// Headless (no visible browser window)
const bro = browser.start({ headless: true })

// Start on a URL
const bro = browser.start('https://example.com')
```

---

## Quick API reference

| Call | What it does |
|---|---|
| `browser.start()` | Opens Chrome, returns `Browser` |
| `bro.page()` | Gets the default tab, returns `Page` |
| `vibe.go(url)` | Navigates to URL |
| `vibe.screenshot()` | Returns `Buffer` (PNG) |
| `vibe.find(selector)` | Finds element by CSS or semantic selector |
| `vibe.find({ role, text })` | Semantic find |
| `el.click()` | Clicks the element |
| `el.fill('value')` | Fills an input |
| `el.text()` | Returns visible text |
| `bro.stop()` | Closes the browser |

---

## Troubleshooting

| Error | Fix |
|---|---|
| `Cannot find module 'vibium'` | Run `npm install vibium` in project folder |
| Browser doesn't open | Check `VIBIUM_SKIP_BROWSER_DOWNLOAD` isn't set; try `npx vibium install` |
| Permission denied (Linux) | Install Chrome deps: `sudo apt-get install -y libgbm1 libnss3 libatk-bridge2.0-0` |
| Gatekeeper warning (macOS) | `xattr -cr "$(npx vibium which chromedriver)"` |

---

→ [[guides/getting-started-mcp]] · → [[reference/architecture]] · → [[reference/api-reference]]
