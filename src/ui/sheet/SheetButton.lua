-- Кнопка листа. tone выбирает набор состояний из палитры: обычная, золотая
-- (главное действие), тихая и опасная. Своей разметки у конкретных кнопок нет —
-- отличаются только props.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SheetButton = {}

local TONES = {
  normal = { colors = "buttonStates", textColor = "buttonText" },
  gold = { colors = "buttonGoldStates", textColor = "buttonTextBright" },
  quiet = { colors = "buttonQuietStates", textColor = "textBody" },
  danger = { colors = "buttonDangerStates", textColor = "buttonTextBright" },
}

SheetButton.defaults = {
  id = "",
  label = "",
  tone = "normal",
  onClick = "",
  -- По умолчанию кнопка занимает ячейку, в которую положена.
  width = "fill",
  height = "fill",
  fontSize = 12,
}

function SheetButton.render(props)
  local p = Component.props(SheetButton.defaults, props)
  local tone = TONES[p.tone]
  if tone == nil then
    error("SheetButton: неизвестный tone '" .. tostring(p.tone) .. "' (normal/gold/quiet/danger)", 0)
  end
  return Component.render(Templates.SheetButton, {
    ID = p.id,
    LABEL = Component.escape(p.label),
    COLORS = Component.color(tone.colors),
    TEXT_COLOR = Component.color(tone.textColor),
    ON_CLICK = p.onClick,
    WIDTH = p.width,
    HEIGHT = p.height,
    FONT_SIZE = p.fontSize,
  })
end

return SheetButton
