# WebDriver BiDi Coverage

Source: `docs/trackers/arewebidiyet.md` · Spec: `w3c.github.io/webdriver-bidi/`

**Legend:** ✅ Done · ⬜ Not started  
**Total:** 63 commands + 24 events = 87 · ✅ 40 · ⬜ 47

---

## Object model

| BiDi concept | Vibium equivalent |
|---|---|
| Session | `browser` (Browser) |
| User Context | `context` (BrowserContext) via `browser.newContext()` |
| Browsing Context | `page` (Page) via `browser.newPage()` |
| Element / Node | `Element` from `page.find()` |
| Realm | (internal) |
| Network Intercept | `route` (Route) via `page.route()` |

---

## Commands (63)

### session (5)
| BiDi | Vibium | ✓ |
|---|---|---|
| `session.status` | `browser.status()` | ⬜ |
| `session.new` | `browser.start(caps?)` | ✅ |
| `session.end` | `browser.stop()` | ✅ |
| `session.subscribe` | (internal) | ⬜ |
| `session.unsubscribe` | (internal) | ⬜ |

### browser (7)
| BiDi | Vibium | ✓ |
|---|---|---|
| `browser.close` | `browser.stop()` | ✅ |
| `browser.createUserContext` | `browser.newContext()` | ✅ |
| `browser.getClientWindows` | `browser.windows()` | ⬜ |
| `browser.getUserContexts` | `browser.contexts()` | ⬜ |
| `browser.removeUserContext` | `context.close()` | ✅ |
| `browser.setClientWindowState` | `page.setWindow()` | ✅ |
| `browser.setDownloadBehavior` | `page.setDownloadBehavior()` | ⬜ |

### browsingContext (13)
| BiDi | Vibium | ✓ |
|---|---|---|
| `browsingContext.activate` | `page.bringToFront()` | ✅ |
| `browsingContext.captureScreenshot` | `page.screenshot()` | ✅ |
| `browsingContext.close` | `page.close()` | ✅ |
| `browsingContext.create` | `browser.newPage()` | ✅ |
| `browsingContext.getTree` | `browser.pages()` / `page.frames()` | ✅ |
| `browsingContext.handleUserPrompt` | `dialog.accept()` / `dialog.dismiss()` | ✅ |
| `browsingContext.locateNodes` | `page.find()` / `page.findAll()` | ✅ |
| `browsingContext.navigate` | `page.go(url)` | ✅ |
| `browsingContext.print` | `page.pdf()` | ✅ |
| `browsingContext.reload` | `page.reload()` | ✅ |
| `browsingContext.setBypassCSP` | `page.setBypassCSP()` | ⬜ |
| `browsingContext.setViewport` | `page.setViewport()` | ✅ |
| `browsingContext.traverseHistory` | `page.back()` / `page.forward()` | ✅ |

### emulation (11)
| BiDi | Vibium | ✓ |
|---|---|---|
| `emulation.setGeolocationOverride` | `page.setGeolocation()` | ✅ |
| `emulation.setForcedColorsModeThemeOverride` | — | ⬜ |
| `emulation.setLocaleOverride` | — | ⬜ |
| `emulation.setNetworkConditions` | — | ⬜ |
| `emulation.setScreenOrientationOverride` | — | ⬜ |
| `emulation.setScreenSettingsOverride` | — | ⬜ |
| `emulation.setScriptingEnabled` | — | ⬜ |
| `emulation.setScrollbarTypeOverride` | — | ⬜ |
| `emulation.setTimezoneOverride` | — | ⬜ |
| `emulation.setTouchOverride` | — | ⬜ |
| `emulation.setUserAgentOverride` | — | ⬜ |

### network (13)
| BiDi | Vibium | ✓ |
|---|---|---|
| `network.addIntercept` | `page.route()` | ✅ |
| `network.continueRequest` | `route.continue()` | ✅ |
| `network.continueResponse` | `route.continue()` | ✅ |
| `network.failRequest` | `route.abort()` | ✅ |
| `network.provideResponse` | `route.fulfill()` | ✅ |
| `network.removeIntercept` | `page.unroute()` | ✅ |
| `network.setExtraHeaders` | `page.setHeaders()` | ✅ |
| `network.addDataCollector` | — | ⬜ |
| `network.continueWithAuth` | `route.authenticate()` | ⬜ |
| `network.disownData` | — | ⬜ |
| `network.getData` | — | ⬜ |
| `network.removeDataCollector` | — | ⬜ |
| `network.setCacheBehavior` | — | ⬜ |

### script (6)
| BiDi | Vibium | ✓ |
|---|---|---|
| `script.addPreloadScript` | `context.addInitScript()` | ✅ |
| `script.callFunction` | `page.evaluate()` | ✅ |
| `script.evaluate` | `page.evaluate()` | ✅ |
| `script.disown` | (internal) | ⬜ |
| `script.getRealms` | — | ⬜ |
| `script.removePreloadScript` | — | ⬜ |

### input (3)
| BiDi | Vibium | ✓ |
|---|---|---|
| `input.performActions` | `page.keyboard.*` / `page.mouse.*` | ✅ |
| `input.setFiles` | `el.setFiles()` | ✅ |
| `input.releaseActions` | (automatic) | ⬜ |

### storage (3)
| BiDi | Vibium | ✓ |
|---|---|---|
| `storage.deleteCookies` | `context.clearCookies()` | ✅ |
| `storage.getCookies` | `context.cookies()` | ✅ |
| `storage.setCookie` | `context.setCookies([c])` | ✅ |

### webExtension (2)
| BiDi | Vibium | ✓ |
|---|---|---|
| `webExtension.install` | — | ⬜ |
| `webExtension.uninstall` | — | ⬜ |

---

## Events (24)

### browsingContext (14)
| BiDi | Vibium | ✓ |
|---|---|---|
| `browsingContext.contextCreated` | `browser.onPage(fn)` | ✅ |
| `browsingContext.downloadWillBegin` | `page.onDownload(fn)` | ✅ |
| `browsingContext.userPromptOpened` | `page.onDialog(fn)` | ✅ |
| `browsingContext.contextDestroyed` | — | ⬜ |
| `browsingContext.domContentLoaded` | — | ⬜ |
| `browsingContext.downloadEnd` | — | ⬜ |
| `browsingContext.fragmentNavigated` | — | ⬜ |
| `browsingContext.historyUpdated` | — | ⬜ |
| `browsingContext.load` | — | ⬜ |
| `browsingContext.navigationAborted` | — | ⬜ |
| `browsingContext.navigationCommitted` | — | ⬜ |
| `browsingContext.navigationFailed` | — | ⬜ |
| `browsingContext.navigationStarted` | — | ⬜ |
| `browsingContext.userPromptClosed` | — | ⬜ |

### input (1)
| BiDi | Vibium | ✓ |
|---|---|---|
| `input.fileDialogOpened` | — | ⬜ |

### log (1)
| BiDi | Vibium | ✓ |
|---|---|---|
| `log.entryAdded` | `page.onConsole(fn)` / `page.onError(fn)` | ✅ |

### network (5)
| BiDi | Vibium | ✓ |
|---|---|---|
| `network.beforeRequestSent` | `page.onRequest(fn)` | ✅ |
| `network.responseCompleted` | `page.onResponse(fn)` | ✅ |
| `network.authRequired` | (via route) | ⬜ |
| `network.fetchError` | — | ⬜ |
| `network.responseStarted` | — | ⬜ |

### script (3)
| BiDi | Vibium | ✓ |
|---|---|---|
| `script.message` | — | ⬜ |
| `script.realmCreated` | — | ⬜ |
| `script.realmDestroyed` | — | ⬜ |

---

## Notable gaps

- **`emulation.*`** — Only geolocation implemented; timezone, locale, network conditions, user-agent all missing
- **`browsingContext.historyUpdated`** — Directly related to open issue JS #126 (SPA pushState not captured) → [[methods/navigate#126]]
- **`browsingContext.fragmentNavigated`** — Same gap for hash-change SPAs
- **`script.addPreloadScript`** — Implemented but `removePreloadScript` missing
- **`network.continueWithAuth`** — Basic auth flows need this

→ [[reference/architecture]] · → [[methods/navigate]]
