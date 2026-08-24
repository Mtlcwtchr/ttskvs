-- Плитка боя (4A: MELEE / ARMOUR CLASS / RANGED под куклой). tone="gold" —
-- выделенная плитка брони.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local CombatTile = {}

CombatTile.defaults = {
  label = "",
  name = "",
  -- Бонусы показываем со знаком, броню — как есть.
  signed = "false",
  tone = "normal",
  width = "fill",
  height = "fill",
}

function CombatTile.render(props)
  local p = Component.props(CombatTile.defaults, props)
  local gold = tostring(p.tone) == "gold"
  local value

  if Common.isWizard() then
    value = Field.render({
      name = p.name,
      fontSize = gold and 20 or 16,
      color = gold and "goldLight" or "textCream",
      alignment = "MiddleCenter",
      height = "fill",
    })
  else
    local raw = Common.value(p.name)
    value = Label.render({
      text = (tostring(p.signed) == "true") and Common.signed(raw) or tostring(raw),
      fontSize = gold and 22 or 17,
      color = gold and "goldLight" or "textCream",
      height = "fill",
    })
  end

  return Component.render(Templates.CombatTile, {
    LABEL = p.label,
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(gold and "bgTileSelected" or "bgTile"),
    BORDER_COLOR = Component.color(gold and "goldBright" or "brass"),
    VALUE = value,
  })
end

return CombatTile
