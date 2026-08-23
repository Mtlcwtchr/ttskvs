local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Stack = {}

Stack.defaults = {
  padding = "0 0 0 0",
  spacing = 4,
  childAlignment = "UpperCenter",
  content = "",
  -- fluid: дети тянутся по ширине (тексты, поля).
  -- fixed: дети сохраняют свой размер (плитки, секции, портреты).
  fit = "fluid",
}

function Stack.render(props)
  local p = Component.props(Stack.defaults, props)
  local template = (p.fit == "fixed") and Templates.StackFixed or Templates.Stack
  return Component.render(template, {
    PADDING = p.padding,
    SPACING = p.spacing,
    CHILD_ALIGNMENT = p.childAlignment,
    CONTENT = p.content,
  })
end

return Stack
