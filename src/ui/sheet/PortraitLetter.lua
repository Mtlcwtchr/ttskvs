-- Заглушка портрета в шапке листа. Первый символ берём как ведущий байт с
-- продолжениями: :sub(1, 1) от «Мира» вернул бы половину буквы.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local PortraitLetter = {}

PortraitLetter.defaults = {
  fontSize = 48,
  color = "goldBright",
}

function PortraitLetter.render(props)
  local p = Component.props(PortraitLetter.defaults, props)
  local name = tostring(Common.character().name or "?")
  return Component.render(Templates.PortraitLetter, {
    LETTER = Component.escape(name:match("^[\1-\127\194-\244][\128-\191]*") or "?"),
    FONT_SIZE = p.fontSize,
    COLOR = p.color,
  })
end

return PortraitLetter
