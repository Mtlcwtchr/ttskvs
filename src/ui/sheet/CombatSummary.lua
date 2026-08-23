local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local CombatSummary = {}

CombatSummary.defaults = { fontSize = 12 }

function CombatSummary.render(props)
  local p = Component.props(CombatSummary.defaults, props)
  return Component.render(Templates.CombatSummary, {
    TEMP = Component.escape(Common.value("field_hp_temp")),
    DICE = Component.escape(Common.value("field_hit_dice")),
    FONT_SIZE = p.fontSize,
  })
end

return CombatSummary
