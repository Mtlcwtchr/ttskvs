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
Theme.railBg = "rgba(0.078,0.063,0.039,0.92)"
-- Прозрачный фон нужен явным значением: у Panel без color свой дефолт.
Theme.transparent = "rgba(0,0,0,0)"

-- Роли для компонентов ui/components/: фон кнопки, фон выбранной кнопки,
-- акцентная рамка (кнопка "+"), нейтральная и опасная кнопка.
Theme.buttonBg = "rgba(0.141, 0.141, 0.110, 0.8)"
Theme.buttonBgSelected = "rgba(0.231, 0.318, 0.176, 0.8)"
Theme.frameAccent = "#b08a2e"
Theme.buttonNeutral = "#7f7752"
Theme.dangerRed = "#8e3b34"

Theme.hpRed = "#cf5136"
Theme.hpRedDark = "#3a140f"
Theme.positiveGreen = "#8fbfa8"
Theme.positiveGreenBright = "#a8d6bf"

-- Разметка называет цвет ролью (color="sheetBg"), а не хексом: палитра
-- остаётся единственным местом, где цвета заданы. Незнакомое значение
-- пропускаем как есть — это литерал вида "#c9a94a" или "rgba(...)".
function Theme.resolve(value)
  if type(value) ~= "string" then
    return value
  end
  return Theme[value] or value
end

return Theme
