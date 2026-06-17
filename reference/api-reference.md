# Vibium API Reference — Cross-Surface Command Table

Source: `docs/reference/api.md` · v26.5.31  
**Total: 148 commands** across Browser, Page, Element, BrowserContext, Keyboard, Mouse, Touch, Clock, Recording, Route, Dialog, Download, and Agent Extras.

Legend: filled = implemented · `⬜` = planned · `—` = not applicable

---

## Browser (9)

| # | Description | CLI | MCP | JS | Python |
|---|---|---|---|---|---|
| 1 | Launch browser | `vibium start` | `browser_start` | `browser.start()` | `browser.start()` |
| 2 | Get default page | — | — | `browser.page()` | `browser.page()` |
| 3 | New page | `vibium page new` | `browser_new_page` | `browser.newPage()` | `browser.new_page()` |
| 4 | New context | — | — | `browser.newContext()` | `browser.new_context()` |
| 5 | List pages | `vibium pages` | `browser_list_pages` | `browser.pages()` | `browser.pages()` |
| 6 | Stop browser | `vibium stop` | `browser_stop` | `browser.stop()` | `browser.stop()` |
| 7 | On new page event | — | — | `browser.onPage(cb)` | `browser.on_page(cb)` |
| 8 | On popup event | — | — | `browser.onPopup(cb)` | `browser.on_popup(cb)` |
| 9 | Remove listeners | — | — | `browser.removeAllListeners()` | `browser.remove_all_listeners()` |

---

## Page (53)

| # | Description | CLI | MCP | JS | Python |
|---|---|---|---|---|---|
| 10 | Navigate | `vibium go <url>` | `browser_navigate` | `page.go(url)` | `page.go(url)` |
| 11 | Back | `vibium back` | `browser_back` | `page.back()` | `page.back()` |
| 12 | Forward | `vibium forward` | `browser_forward` | `page.forward()` | `page.forward()` |
| 13 | Reload | `vibium reload` | `browser_reload` | `page.reload()` | `page.reload()` |
| 14 | Get URL | `vibium url` | `browser_get_url` | `page.url()` | `page.url()` |
| 15 | Get title | `vibium title` | `browser_get_title` | `page.title()` | `page.title()` |
| 16 | Get HTML | — | — | `page.content()` | `page.content()` |
| 17 | Find element | `vibium find <sel>` | `browser_find` | `page.find(sel, opts?)` | `page.find(sel, **opts)` |
| 18 | Find all | `vibium find --all <sel>` | `browser_find_all` | `page.findAll(sel, opts?)` | `page.find_all(sel, **opts)` |
| 19 | Screenshot | `vibium screenshot` | `browser_screenshot` | `page.screenshot(opts?)` | `page.screenshot(opts?)` |
| 20 | PDF | `vibium pdf` | `browser_pdf` | `page.pdf()` | `page.pdf()` |
| 21 | Evaluate JS | `vibium eval <expr>` | `browser_evaluate` | `page.evaluate(expr)` | `page.evaluate(expr)` |
| 22 | Add script | ⬜ | ⬜ | `page.addScript(src)` | `page.add_script(src)` |
| 23 | Add style | ⬜ | ⬜ | `page.addStyle(src)` | `page.add_style(src)` |
| 24 | Expose function | — | — | `page.expose(name, fn)` | `page.expose(name, fn)` |
| 25 | Wait (ms) | `vibium sleep <ms>` | `browser_sleep` | `page.wait(ms)` | `page.wait(ms)` |
| 26 | Wait for selector | `vibium wait <sel>` | `browser_wait` | `page.waitFor(sel, opts?)` | `page.wait_for(sel)` |
| 27 | Wait for function | `vibium wait fn <expr>` | `browser_wait_for_fn` | `page.waitForFunction(fn, opts?)` | `page.wait_for_function(fn)` |
| 28 | Wait for URL | `vibium wait url <pat>` | `browser_wait_for_url` | `page.waitForURL(url, opts?)` | `page.wait_for_url(url)` |
| 29 | Wait for load | `vibium wait load` | `browser_wait_for_load` | `page.waitForLoad(opts?)` | `page.wait_for_load()` |
| 30 | Scroll page | `vibium scroll <dir> <amt>` | `browser_scroll` | `page.scroll(dir?, amt?, sel?)` | `page.scroll()` |
| 31 | Set viewport | `vibium viewport <w> <h>` | `browser_set_viewport` | `page.setViewport(size)` | `page.set_viewport(size)` |
| 32 | Get viewport | `vibium viewport get` | `browser_get_viewport` | `page.viewport()` | `page.viewport()` |
| 33 | Emulate media | `vibium media <scheme>` | `browser_emulate_media` | `page.emulateMedia(opts)` | `page.emulate_media()` |
| 34 | Set content | `vibium content <html>` | `browser_set_content` | `page.setContent(html)` | `page.set_content(html)` |
| 35 | Set geolocation | `vibium geolocation <lat> <lon>` | `browser_set_geolocation` | `page.setGeolocation(coords)` | `page.set_geolocation(coords)` |
| 36 | Set window | `vibium window <opts>` | `browser_set_window` | `page.setWindow(opts)` | `page.set_window()` |
| 37 | Get window | `vibium window get` | `browser_get_window` | `page.window()` | `page.window()` |
| 38 | A11y tree | `vibium a11y-tree` | `browser_a11y_tree` | `page.a11yTree(opts?)` | `page.a11y_tree()` |
| 39 | List frames | `vibium frames` | `browser_frames` | `page.frames()` | `page.frames()` |
| 40 | Get frame | `vibium frame <ref>` | `browser_frame` | `page.frame(nameOrUrl)` | `page.frame()` |
| 41 | Main frame | — | — | `page.mainFrame()` | `page.main_frame()` |
| 42 | Switch page | `vibium page switch <idx>` | `browser_switch_page` | `page.bringToFront()` | `page.bring_to_front()` |
| 43 | Close page | `vibium page close` | `browser_close_page` | `page.close()` | `page.close()` |
| 44 | Route | — | — | `page.route(pattern, handler)` | `page.route(pattern, handler)` |
| 45 | Unroute | — | — | `page.unroute(pattern)` | `page.unroute(pattern)` |
| 46 | Set headers | ⬜ | ⬜ | `page.setHeaders(headers)` | `page.set_headers(headers)` |
| 47–54 | Event listeners | — | — | `page.on*(fn)` | `page.on_*(fn)` |
| 55 | Capture response | — | — | `page.capture.response()` | `page.capture.response()` |
| 56 | Capture request | — | — | `page.capture.request()` | `page.capture.request()` |
| 57 | Capture navigation | — | — | `page.capture.navigation()` | `page.capture.navigation()` |
| 58 | Capture event | — | — | `page.capture.event()` | `page.capture.event()` |
| 59 | Capture download | — | — | `page.capture.download()` | `page.capture.download()` |
| 60 | Capture dialog | — | — | `page.capture.dialog()` | `page.capture.dialog()` |
| 61 | Console messages | — | — | `page.consoleMessages()` | `page.console_messages()` |
| 62 | Page errors | — | — | `page.errors()` | `page.errors()` |

---

## Element (34)

| # | Description | CLI | MCP | JS | Python |
|---|---|---|---|---|---|
| 63 | Click | `vibium click <sel>` | `browser_click` | `el.click()` | `el.click()` |
| 64 | Double-click | `vibium dblclick <sel>` | `browser_dblclick` | `el.dblclick()` | `el.dblclick()` |
| 65 | Fill | `vibium fill <sel> <val>` | `browser_fill` | `el.fill(value)` | `el.fill(value)` |
| 66 | Type | `vibium type <text>` | `browser_type` | `el.type(text)` | `el.type(text)` |
| 67 | Press key | `vibium press <key>` | `browser_press` | `el.press(key)` | `el.press(key)` |
| 68 | Clear | — | — | `el.clear()` | `el.clear()` |
| 69 | Check | `vibium check <sel>` | `browser_check` | `el.check()` | `el.check()` |
| 70 | Uncheck | `vibium uncheck <sel>` | `browser_uncheck` | `el.uncheck()` | `el.uncheck()` |
| 71 | Select option | `vibium select <sel> <val>` | `browser_select` | `el.selectOption(val)` | `el.select_option(val)` |
| 72 | Hover | `vibium hover <sel>` | `browser_hover` | `el.hover()` | `el.hover()` |
| 73 | Focus | `vibium focus <sel>` | `browser_focus` | `el.focus()` | `el.focus()` |
| 74 | Drag to | `vibium drag <sel> <x> <y>` | `browser_drag` | `el.dragTo(target)` | `el.drag_to(target)` |
| 75 | Tap | — | — | `el.tap()` | `el.tap()` |
| 76 | Scroll into view | `vibium scroll into-view <sel>` | `browser_scroll_into_view` | `el.scrollIntoView()` | `el.scroll_into_view()` |
| 77 | Dispatch event | — | — | `el.dispatchEvent(type)` | `el.dispatch_event(type)` |
| 78 | Set files | `vibium upload <sel> <paths>` | `browser_upload` | `el.setFiles(files)` | `el.set_files(files)` |
| 79 | Highlight | `vibium highlight <sel>` | `browser_highlight` | `el.highlight()` | `el.highlight()` |
| 80 | Get text | `vibium text <sel>` | `browser_get_text` | `el.text()` | `el.text()` |
| 81 | Inner text | `vibium text <sel>` | `browser_get_text` | `el.innerText()` | `el.inner_text()` |
| 82 | Outer HTML | `vibium html <sel>` | `browser_get_html` | `el.html()` | `el.html()` |
| 83 | Input value | `vibium value <sel>` | `browser_get_value` | `el.value()` | `el.value()` |
| 84 | Get attribute | `vibium attr <sel> <name>` | `browser_get_attribute` | `el.attr(name)` | `el.attr(name)` |
| 85 | Bounding box | — | — | `el.bounds()` | `el.bounds()` |
| 86 | Is visible | `vibium is visible <sel>` | `browser_is_visible` | `el.isVisible()` | `el.is_visible()` |
| 87 | Is hidden | — | — | `el.isHidden()` | `el.is_hidden()` |
| 88 | Is enabled | `vibium is enabled <sel>` | `browser_is_enabled` | `el.isEnabled()` | `el.is_enabled()` |
| 89 | Is checked | `vibium is checked <sel>` | `browser_is_checked` | `el.isChecked()` | `el.is_checked()` |
| 90 | Is editable | ⬜ | ⬜ | `el.isEditable()` | `el.is_editable()` |
| 91 | ARIA role | — | — | `el.role()` | `el.role()` |
| 92 | Accessible label | — | — | `el.label()` | `el.label()` |
| 93 | Element screenshot | — | — | `el.screenshot()` | `el.screenshot()` |
| 94 | Wait for state | `vibium wait <sel> --state <st>` | `browser_wait` | `el.waitUntil(state?)` | `el.wait_until(state?)` |
| 95 | Find child | — | — | `el.find(sel)` | `el.find(sel)` |
| 96 | Find all children | — | — | `el.findAll(sel)` | `el.find_all(sel)` |

---

## BrowserContext (9)

| # | Description | CLI | MCP | JS | Python |
|---|---|---|---|---|---|
| 97 | New page in context | — | — | `context.newPage()` | `context.new_page()` |
| 98 | Close context | — | — | `context.close()` | `context.close()` |
| 99 | Get cookies | `vibium cookies` | `browser_get_cookies` | `context.cookies()` | `context.cookies()` |
| 100 | Set cookies | `vibium cookies set <n> <v>` | `browser_set_cookie` | `context.setCookies()` | `context.set_cookies()` |
| 101 | Clear cookies | `vibium cookies clear` | `browser_delete_cookies` | `context.clearCookies()` | `context.clear_cookies()` |
| 102 | Get storage state | `vibium storage` | `browser_storage_state` | `context.storage()` | `context.storage()` |
| 103 | Set storage state | — | `browser_restore_storage` | `context.setStorage()` | `context.set_storage()` |
| 104 | Clear all storage | — | — | `context.clearStorage()` | `context.clear_storage()` |
| 105 | Add init script | — | — | `context.addInitScript()` | `context.add_init_script()` |

---

## Keyboard (4) · Mouse (5) · Touch (1)

| # | Description | CLI | MCP | JS | Python |
|---|---|---|---|---|---|
| 106 | Press key | `vibium keys <keys>` | `browser_keys` | `keyboard.press(key)` | `keyboard.press(key)` |
| 107 | Key down | — | — | `keyboard.down(key)` | `keyboard.down(key)` |
| 108 | Key up | — | — | `keyboard.up(key)` | `keyboard.up(key)` |
| 109 | Type text | — | — | `keyboard.type(text)` | `keyboard.type(text)` |
| 110 | Mouse click | `vibium mouse click <x> <y>` | `browser_mouse_click` | `mouse.click(x, y)` | `mouse.click(x, y)` |
| 111 | Mouse move | `vibium mouse move <x> <y>` | `browser_mouse_move` | `mouse.move(x, y)` | `mouse.move(x, y)` |
| 112 | Mouse down | `vibium mouse down` | `browser_mouse_down` | `mouse.down()` | `mouse.down()` |
| 113 | Mouse up | `vibium mouse up` | `browser_mouse_up` | `mouse.up()` | `mouse.up()` |
| 114 | Mouse wheel | — | ⬜ | `mouse.wheel(dx, dy)` | `mouse.wheel(dx, dy)` |
| 115 | Touch tap | — | — | `touch.tap(x, y)` | `touch.tap(x, y)` |

---

## Clock (8) · Recording (6) · Route (4) · Dialog (6) · Download (4)

See full table in `docs/reference/api.md` (items 116–142).

Key notes:
- Clock: all 8 ops CLI-only via MCP (`page_clock_*`) — no CLI equivalent
- Recording: full recording / chunk / group pattern in CLI, MCP, JS, Python
- Route/Dialog/Download: JS/Python only (no CLI or MCP equivalents)

---

## Agent / CLI Extras (5)

| # | Description | CLI | MCP |
|---|---|---|---|
| 143 | Map interactive elements with @refs | `vibium map` | `browser_map` |
| 144 | Diff vs last map | `vibium diff` | `browser_diff_map` |
| 145 | Count matching elements | `vibium count <sel>` | `browser_count` |
| 146 | Wait for text | `vibium wait text <text>` | `browser_wait_for_text` |
| 147 | Set download directory | `vibium download set-dir <path>` | `browser_download_set_dir` |

---

## AI-Native (Planned — not yet implemented)

| # | Description | JS | Python |
|---|---|---|---|
| 148 | AI-native methods: assert visual claim · natural language action | `page.check(claim)` · `page.do(action, data?)` | `page.check(claim)` · `page.do(action, data=...)` |

---

## Gaps (planned, not yet implemented)

| Feature | CLI | MCP |
|---|---|---|
| `addScript` / `addStyle` | ⬜ | ⬜ |
| `setHeaders` | ⬜ | ⬜ |
| `isEditable` | ⬜ | ⬜ |
| `download.saveAs` | ⬜ | ⬜ |
| `mouse.wheel` | — | ⬜ |
| AI-native: `check`, `do` | ⬜ | ⬜ |

→ [[reference/api-surface]] · → [[reference/actionability]]
