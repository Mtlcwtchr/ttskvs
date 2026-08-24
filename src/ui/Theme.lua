-- Единая палитра для всей разметки. Взята из дизайн-референса «BG3 and D&D
-- Sheet Fusion», секция 4A («Ashgrave Codex · character window»): тёплое
-- обожжённое золото по углю, вместо прежнего оливково-золотого.
--
-- Значения перенесены из мокапа как есть. Чего в TTS воспроизвести нельзя —
-- градиентов, внутренних теней, свечения, кованых уголков — того здесь нет:
-- берётся один тон градиента (обычно верхний), рамка становится сплошной.
-- Появятся 9-slice PNG — вернём фаски, роли останутся те же.
local Theme = {}

-- ── подложки: от окна к самой тёмной ячейке ──────────────────────────────
-- (в мокапе: window #1a120c, панели #2f2318/#241a12, кант #100b07)
Theme.bgWindow = "#1a120c"
Theme.bgPanel = "#241a12"
Theme.bgPanelLight = "#2f2318"
Theme.bgTile = "#4a3826"
Theme.bgTileDeep = "#221912"
Theme.bgTileSelected = "#5c4419"
Theme.bgEmpty = "#1a120c"
Theme.bgDeepest = "#100b07"
Theme.bgTrack = "#100b07"
Theme.bgInput = "#150e09"

-- Окно листа и рейка — почти непрозрачные: под ними стол.
-- ВАЖНО: в rgba(r,g,b,a) все четыре компонента 0..1 (НЕ 0..255, в отличие от
-- CSS) — иначе парсер молча оставит блок прозрачным.
Theme.sheetBg = "rgba(0.102,0.071,0.047,0.97)"
Theme.railBg = "rgba(0.082,0.055,0.035,0.90)"
Theme.overlayDark = "rgba(0.059,0.043,0.027,0.60)"
-- Прозрачный фон нужен явным значением: у Panel без color свой дефолт.
Theme.transparent = "rgba(0,0,0,0)"

-- ── золото и латунь ─────────────────────────────────────────────────────
Theme.gold = "#d9b877"
Theme.goldBright = "#efdcae"
Theme.goldPale = "#f4e7cb"
Theme.goldLight = "#fdf3d8"
Theme.goldDim = "#b08d57"
Theme.labelGold = "#b08d57"
Theme.slotLabel = "#c8a26a"
Theme.brass = "#8a7048"
Theme.brassDim = "#6d5636"
Theme.borderDim = "#57452c"
Theme.borderBrass = "#8a7048"
Theme.divider = "#4a3c28"
Theme.borderFaint = "#3d3122"
Theme.frameAccent = "#d9b877"

-- ── текст ───────────────────────────────────────────────────────────────
Theme.textBright = "#fdf3d8"
Theme.textName = "#f4e7cb"
Theme.textValue = "#f0dfb2"
Theme.textCream = "#ecdcb4"
Theme.textBody = "#b0a288"
Theme.textMuted = "#8a7f6c"
Theme.textMuted2 = "#7d7160"
Theme.textFaint = "#6b6152"

-- ── состояния ───────────────────────────────────────────────────────────
Theme.hpRed = "#cf5136"
Theme.hpRedDark = "#7c1d14"
Theme.warmOrange = "#dba881"
Theme.hostileRed = "#7d4238"
Theme.dangerRed = "#7d4238"
-- Стамина и мана — наши, в мокапе 4A их нет: берём соседние тона палитры,
-- чтобы три полоски различались (уголь-красный / латунь / холодная сталь).
Theme.staminaGold = "#d9b877"
Theme.manaBlue = "#7f9bb5"

-- ── кнопки и поля: четыре состояния через `colors` ───────────────────────
-- У Button и InputField в TTS цвет задаётся атрибутом `colors` —
-- normal|highlighted|pressed|disabled (api.tabletopsimulator.com/ui/inputelements).
-- Дефолт там белый, поэтому не указать его — значит получить белую кнопку.
Theme.buttonStates = "#3a2b1c|#4d3a26|#5c4419|rgba(0.16,0.12,0.08,0.40)"
Theme.buttonGoldStates = "#5c4419|#70521f|#856128|rgba(0.16,0.12,0.08,0.40)"
Theme.buttonDangerStates = "#5a2a24|#7d4238|#94503f|rgba(0.16,0.12,0.08,0.40)"
Theme.buttonQuietStates = "#2c2013|#3a2b1c|#4a3826|rgba(0.16,0.12,0.08,0.40)"
Theme.portraitStates = "#3a2d1e|#4a3826|#5c4419|rgba(0.16,0.12,0.08,0.40)"
Theme.portraitSelectedStates = "#4a3826|#5c4419|#6d5322|rgba(0.16,0.12,0.08,0.40)"
Theme.seatStates = "#1f1710|#2a1f14|#33261a|rgba(0.16,0.12,0.08,0.40)"
Theme.inputStates = "#150e09|#1d140c|#241a12|rgba(0.08,0.06,0.04,0.50)"

-- Tекст на кнопках и в полях: по умолчанию TTS красит его в #323232, то есть
-- тёмным по тёмному — читать нечего.
Theme.buttonText = "#ecdcb4"
Theme.buttonTextBright = "#fdf3d8"
Theme.inputText = "#ecdcb4"
Theme.caret = "#d9b877"
Theme.seatText = "#6a5427"
Theme.emptySeatBorder = "#4b3a18"

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
