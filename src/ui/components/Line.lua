local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Line = {}

Line.defaults = {
  padding = "0 0 0 0",
  spacing = 6,
  childAlignment = "MiddleCenter",
  content = "",
  -- fluid: дети тянутся по ширине (тексты, поля).
  -- fixed: дети сохраняют свой размер (плитки, секции, портреты).
  fit = "fluid",
}

function Line.render(props)
  local p = Component.props(Line.defaults, props)
  local template = (p.fit == "fixed") and Templates.LineFixed or Templates.Line
  return Component.render(template, {
    PADDING = p.padding,
    SPACING = p.spacing,
    CHILD_ALIGNMENT = p.childAlignment,
    CONTENT = p.content,
  })
end

return Line
