-- Плитка характеристики (4A, колонка 1): подпись, значение, модификатор
-- пилюлей снизу.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Templates = require("ui.generated.Templates")

local AbilityTile = {}

AbilityTile.defaults = {
  label = "",
  name = "",
  width = "fill",
  height = "fill",
}

function AbilityTile.render(props)
  local p = Component.props(AbilityTile.defaults, props)
  local sub = ""
  if not Common.isWizard() then
    sub = Common.signed(Common.modifier(Common.value(p.name)))
  end
  return Component.render(Templates.AbilityTile, {
    LABEL = p.label,
    SUB = sub,
    WIDTH = p.width,
    HEIGHT = p.height,
    VALUE = Field.render({
      name = p.name,
      fontSize = 22,
      color = "goldLight",
      alignment = "MiddleCenter",
      height = "fill",
    }),
  })
end

return AbilityTile
