-- Портрет партии (4A): выделенный крупнее и в светлой рамке, под плиткой —
-- табличка хитов. От любой другой кнопки отличается только props.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local PortraitButton = {}

PortraitButton.defaults = {
  characterId = "",
  initial = "?",
  hp = "",
  hpLow = false,
  selected = false,
  size = 72,
  selectedSize = 78,
  border = 1,
  selectedBorder = 2,
  onClick = "selectCharacter",
}

function PortraitButton.render(props)
  local p = Component.props(PortraitButton.defaults, props)
  local selected = p.selected == true or p.selected == "true"
  local low = p.hpLow == true or p.hpLow == "true"

  return Component.render(Templates.PortraitButton, {
    ID = "character_" .. p.characterId,
    INITIAL = p.initial,
    HP = p.hp,
    SIZE = selected and p.selectedSize or p.size,
    BORDER = selected and p.selectedBorder or p.border,
    INITIAL_FONT_SIZE = selected and 30 or 26,
    ON_CLICK = p.onClick,
    BORDER_COLOR = Component.color(selected and "gold" or "brassDim"),
    COLORS = Component.color(selected and "portraitSelectedStates" or "portraitStates"),
    INITIAL_COLOR = Component.color(selected and "goldPale" or "textBody"),
    HP_BORDER_COLOR = Component.color(low and "hostileRed" or "brass"),
    HP_COLOR = Component.color(low and "warmOrange" or "textCream"),
  })
end

return PortraitButton
