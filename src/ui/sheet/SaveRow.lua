-- Строка спасброска. Разметка — layout/SaveRow.xml, здесь только арифметика:
-- модификатор характеристики плюс бонус мастерства при владении.
-- Клик по точке переключает владение (toggleSave в HUDEvents).
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SaveRow = {}

SaveRow.defaults = {
  ability = "",
  label = "",
  fontSize = 12,
}

function SaveRow.render(props)
  local p = Component.props(SaveRow.defaults, props)
  local proficient = Common.hasProficiency(Common.character().savingThrowProficiencies, p.ability)
  local bonus = Common.modifier(Common.value("field_ability_" .. p.ability))
    + (proficient and (tonumber(Common.value("field_proficiency_bonus")) or 0) or 0)
  local dotColor = Component.color(proficient and "goldBright" or "bgWindow")

  return Component.render(Templates.SaveRow, {
    DOT_ID = "save_" .. p.ability,
    DOT_COLORS = dotColor .. "|" .. dotColor .. "|" .. dotColor .. "|" .. dotColor,
    DOT_BORDER = Component.color(proficient and "goldBright" or "brassDim"),
    BONUS = Common.signed(bonus),
    LABEL = Component.escape(p.label),
    FONT_SIZE = p.fontSize,
    COLOR = proficient and "textCream" or "textMuted",
  })
end

return SaveRow
