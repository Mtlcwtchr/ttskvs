local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local Experience = {}

Experience.defaults = {
  fontSize = 14,
  color = "textBody",
}

function Experience.render(props)
  local p = Component.props(Experience.defaults, props)
  return Component.render(Templates.Experience, {
    CURRENT = Component.escape(Common.value("field_xp_current")),
    NEXT = Component.escape(Common.value("field_xp_next")),
    FONT_SIZE = p.fontSize,
    COLOR = p.color,
  })
end

return Experience
