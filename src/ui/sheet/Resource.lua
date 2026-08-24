-- Ресурс полоской (4A, блок HIT POINTS): подпись слева, значение справа,
-- полоска под ними. Стамина и мана — тем же компонентом, другой цвет заливки.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local Resource = {}

Resource.defaults = {
  title = "",
  current = "",
  max = "",
  width = "fill",
  height = 46,
  fillColor = "hpRed",
  trackColor = "bgTrack",
}

function Resource.render(props)
  local p = Component.props(Resource.defaults, props)
  local current = tonumber(Common.value(p.current)) or 0
  local max = tonumber(Common.value(p.max)) or 0
  local value

  if Common.isWizard() then
    value = Component.render(Templates.ResourceEditRow, {
      FIELD_HEIGHT = "fill",
      CURRENT = Field.render({ name = p.current, height = "fill", fontSize = 12, alignment = "MiddleCenter" }),
      MAX = Field.render({ name = p.max, height = "fill", fontSize = 12, alignment = "MiddleCenter" }),
    })
  else
    value = Label.render({
      text = (max > 0) and (current .. " / " .. max) or "—",
      fontSize = 15,
      alignment = "MiddleRight",
      color = (max > 0) and "textCream" or "textMuted",
      height = "fill",
    })
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
