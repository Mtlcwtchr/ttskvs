local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Anchor = {}

Anchor.defaults = {
  alignment = "MiddleCenter",
  offset = "0 0",
  width = 100,
  height = 100,
  color = Theme.transparent,
  content = "",
}

function Anchor.render(props)
  local p = Component.props(Anchor.defaults, props)
  return Component.render(Templates.Anchor, {
    ALIGNMENT = p.alignment,
    OFFSET = p.offset,
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    CONTENT = p.content,
  })
end

return Anchor
