-- Портрет персонажа: от любой другой кнопки отличается только props —
-- цветами по выделению и содержимым. Разметка — layout/PortraitButton.xml.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local PortraitButton = {}

PortraitButton.defaults = {
  characterId = "",
  initial = "?",
  hp = "",
  selected = false,
  onClick = "selectCharacter",
}

function PortraitButton.render(props)
  local p = Component.props(PortraitButton.defaults, props)
  local selected = p.selected == true or p.selected == "true"

  return Component.render(Templates.PortraitButton, {
    ID = "character_" .. p.characterId,
    INITIAL = p.initial,
    HP = p.hp,
    ON_CLICK = p.onClick,
    BORDER_COLOR = Component.color(selected and "goldBright" or "textMuted2"),
    BG_COLOR = Component.color(selected and "buttonBgSelected" or "buttonBg"),
  })
end

return PortraitButton
