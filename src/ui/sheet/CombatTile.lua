local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local CombatTile = {}

CombatTile.defaults = {
  label = "",
  name = "",
  -- Бонусы показываем со знаком, броню и скорость — как есть.
  signed = "false",
  width = 145,
  height = 62,
}

function CombatTile.render(props)
  local p = Component.props(CombatTile.defaults, props)
  local value

  if Common.isWizard() then
    value = Field.render({ name = p.name, fontSize = 18, width = p.width - 15, height = 24 })
  else
    local raw = Common.value(p.name)
    value = Label.render({
      text = (tostring(p.signed) == "true") and Common.signed(raw) or tostring(raw),
      fontSize = 20,
      color = "textBright",
    })
  end

  return Component.render(Templates.CombatTile, {
    LABEL = p.label,
    WIDTH = p.width,
    HEIGHT = p.height,
    VALUE = value,
  })
end

return CombatTile
