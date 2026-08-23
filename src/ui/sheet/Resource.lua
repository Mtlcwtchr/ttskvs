local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Line = require("ui.components.Line")
local Templates = require("ui.generated.Templates")

local Resource = {}

Resource.defaults = {
  title = "",
  current = "",
  max = "",
  width = 195,
  height = 110,
  fillColor = "hpRed",
  trackColor = "hpRedDark",
}

function Resource.render(props)
  local p = Component.props(Resource.defaults, props)
  local current = tonumber(Common.value(p.current)) or 0
  local max = tonumber(Common.value(p.max)) or 0
  local value

  if Common.isWizard() then
    value = Line.render({
      fit = "fixed",
      spacing = 4,
      content = Component.join({
        Field.render({ name = p.current, width = 80, height = 24 }),
        Field.render({ name = p.max, width = 80, height = 24 }),
      }),
    })
  elseif max <= 0 then
    value = Label.render({ text = "—", fontSize = 18, color = "textMuted" })
  else
    value = Label.render({ text = current .. " / " .. max, fontSize = 18, color = "textBright" })
  end

  return Component.render(Templates.Resource, {
    TITLE = p.title,
    WIDTH = p.width,
    HEIGHT = p.height,
    RATIO = string.format("%.4f", max > 0 and (current / max) or 0),
    FILL_COLOR = p.fillColor,
    TRACK_COLOR = p.trackColor,
    VALUE = value,
  })
end

return Resource
