local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Box = {}

Box.defaults = {
  width = 100,
  height = 100,
  color = Theme.bgTile,
  content = "",
}

function Box.render(props)
  local p = Component.props(Box.defaults, props)
  return Component.render(Templates.Box, {
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    CONTENT = p.content,
  })
end

return Box
