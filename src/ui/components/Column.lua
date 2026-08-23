local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Column = {}

Column.defaults = {
  width = 200,
  height = 100,
  -- Колонка вёрстки по умолчанию невидима: цвет задаётся, когда нужна плитка.
  color = Theme.transparent,
  padding = "0 0 0 0",
  spacing = 8,
  childAlignment = "UpperCenter",
  content = "",
  -- fluid: дети тянутся по ширине (тексты, поля).
  -- fixed: дети сохраняют свой размер (плитки, секции, портреты).
  fit = "fluid",
}

function Column.render(props)
  local p = Component.props(Column.defaults, props)
  local template = (p.fit == "fixed") and Templates.ColumnFixed or Templates.Column
  return Component.render(template, {
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    PADDING = p.padding,
    SPACING = p.spacing,
    CHILD_ALIGNMENT = p.childAlignment,
    CONTENT = p.content,
  })
end

return Column
