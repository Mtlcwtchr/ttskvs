local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local ClassLine = {}

ClassLine.defaults = {
  fontSize = 12,
  color = "textMuted",
}

function ClassLine.render(props)
  local p = Component.props(ClassLine.defaults, props)
  return Component.render(Templates.ClassLine, {
    RACE = Component.escape(Common.value("field_race")),
    CLASS = Component.escape(Common.value("field_class")),
    LEVEL = Component.escape(Common.value("field_level")),
    FONT_SIZE = p.fontSize,
    COLOR = p.color,
  })
end

return ClassLine
