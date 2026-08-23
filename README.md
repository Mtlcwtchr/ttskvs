# kvs_tts

Скрипты Tabletop Simulator для сейва KVS.

## Где лежат исходники

`.tts/objects/` — точки входа объектов (`Global.lua`, `Global.xml`, далее `<Имя>.<guid>.lua`).
Это папка, которую использует расширение **TTS Editor** (`sebaestschjin.tts-editor`) для Get Objects/Save and Play;
`.tts/bundled/` оно генерирует само — руками не править.

`src/` — переиспользуемые Lua-модули, на которые точки входа ссылаются через
`require("path.To.Module")` (например `require("ui.HUD")` → `src/ui/HUD.lua`).
`includePath` в настройках расширения = `src`. Это НЕ дубликат `.tts/objects/` —
не удалять, там реальный код (см. `CLAUDE.md`).

## Хоткеи (VS Code)

| Клавиши | Действие |
|---|---|
| `Ctrl+Alt+L` / `Cmd+Alt+L` | Get Objects — забрать скрипты из запущенной игры в `.tts/objects/` |
| `Ctrl+Alt+S` / `Cmd+Alt+S` | Save and Play — отправить `.tts/objects/` в игру (перезагрузит сейв) |
| `Ctrl+Alt+Shift+S` | Save and Play (Bundled) |
| `Ctrl+Alt+E` | Execute Code — выполнить код из активного редактора |
| ``Ctrl+Alt+` `` | Show Output — лог расширения |

Важно: **Save and Play отправляет только те объекты, которые расширение уже знает.**
После перезапуска VS Code сначала `Ctrl+Alt+L`, потом `Ctrl+Alt+S` — список объектов
живёт в памяти расширения и на диск не сохраняется.

Хоткеи заданы в `~/Library/Application Support/Code/User/keybindings.json`.

## CLI-фолбэк

`tools/tts_bridge.py` делает то же самое без VS Code, в том же формате файлов:

```
python3 tools/tts_bridge.py pull    # из игры в .tts/objects/
python3 tools/tts_bridge.py push    # из .tts/objects/ в игру (Save & Play)
python3 tools/tts_bridge.py watch   # живой лог print()/ошибок из игры
```

Скрипт и расширение слушают один порт 39998, и запущенный скрипт перехватывает
ответ игры. Пользуйтесь чем-то одним за раз: пока висит `watch`, хоткеи
расширения не получат ответ из игры.

## Известная проблема

`rolandostar.tabletopsimulator-lua` 1.1.3 не запускается на VS Code 1.128 —
читает `onig.wasm` из `node_modules.asar`, где его больше нет
(`Error: ENOENT, vscode-oniguruma/release/onig.wasm not found`). Его команды
`ttslua.*` отвязаны от хоткеев, само расширение можно удалить.
