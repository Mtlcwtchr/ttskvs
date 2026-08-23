local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Sheet = {}

Sheet.defaults = {
  width = 1320,
  height = 900,
  color = Theme.sheetBg,
  content = "",
}

function Sheet.render(props)
  local p = Component.props(Sheet.defaults, props)
  return Component.render(Templates.Sheet, {
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    CONTENT = p.content,
  })
end

return Sheet
