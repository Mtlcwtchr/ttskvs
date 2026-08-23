-- Единая палитра для всех билдеров. Взято из дизайн-референса "Adventurer HUD"
-- (Claude Design, секция 3a) — тёмное золото на оливково-чёрном. Без
-- градиентов/теней/фасок (TTS XML их не умеет без готовых PNG-текстур,
-- см. CLAUDE.md) — сплошные цвета, но та же ролевая система.
local Theme = {}

Theme.bgDeepest = "#0c0b0a"
Theme.bgPanel = "#141710"
Theme.bgPanelLight = "#1c2013"
Theme.bgTile = "#12150e"
Theme.borderDim = "#4f4520"
Theme.borderBrass = "#6f5f2a"

Theme.gold = "#c9a94a"
Theme.goldBright = "#e6cd85"
Theme.goldDim = "#8a7530"
Theme.labelGold = "#a89328"

Theme.textCream = "#f0dfae"
Theme.textBright = "#fbf0cd"
Theme.textBody = "#e0d7bf"
Theme.textMuted = "#a1966f"
Theme.textMuted2 = "#7f7752"

-- ВАЖНО: rgba(r,g,b,a) в TTS — r/g/b тоже 0..1 (НЕ 0..255!). Раньше здесь
-- были значения вида rgba(12,11,10,0.6) — вне диапазона, парсер их не
-- принимал, и фон панели оставался полностью прозрачным (виден стол под UI).
Theme.overlayDark = "rgba(0.047,0.043,0.039,0.6)"
Theme.sheetBg = "rgba(0.078,0.063,0.039,0.96)"

Theme.hpRed = "#cf5136"
Theme.hpRedDark = "#3a140f"
Theme.positiveGreen = "#8fbfa8"
Theme.positiveGreenBright = "#a8d6bf"

return Theme
