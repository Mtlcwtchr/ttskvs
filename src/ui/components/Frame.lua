-- Рамка вокруг ребёнка. Толщина — отступ, а не «ребёнок меньше на 6»:
-- ребёнок объявляет width="fill" и подстраивается сам.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Frame = {}

Frame.defaults = {
  width = "fill",
  height = "fill",
  border = 3,
  borderColor = Theme.textMuted2,
  content = "",
}

function Frame.render(props)
  local p = Component.props(Frame.defaults, props)
  return Component.render(Templates.Frame, {
    WIDTH = p.width,
    HEIGHT = p.height,
    BORDER = p.border,
    BORDER_COLOR = Component.color(p.borderColor),
    CONTENT = p.content,
  })
end

return Frame
