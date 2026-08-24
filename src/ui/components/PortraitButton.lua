-- Портрет партии (4A): выделенный крупнее и в светлой рамке, под плиткой —
-- табличка хитов. От любой другой кнопки отличается только props.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local PortraitButton = {}

PortraitButton.defaults = {
  characterId = "",
  initial = "?",
  portraitImage = "",
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

  -- Кнопку собираем в Lua: image="" ломает TTS, поэтому атрибут условный
  local btnId = "character_" .. p.characterId
  local colors = Component.color(selected and "portraitSelectedStates" or "portraitStates")
  local textColor = Component.color(selected and "goldPale" or "textBody")
  local fontSize = selected and 30 or 26
  local imageAttr = ""
  if p.portraitImage ~= "" then
    imageAttr = ' image="' .. p.portraitImage .. '"'
  end
  local button = '<Button id="' .. btnId .. '" width="fill" height="fill"'
    .. ' colors="' .. colors .. '"'
    .. ' textColor="' .. textColor .. '"'
    .. imageAttr
    .. ' textAlignment="MiddleCenter"'
    .. ' fontSize="' .. fontSize .. '"'
    .. ' onClick="' .. p.onClick .. '"'
    .. '>' .. (p.portraitImage ~= "" and "" or p.initial) .. '</Button>'

  return Component.render(Templates.PortraitButton, {
    BUTTON = button,
    HP = p.hp,
    SIZE = selected and p.selectedSize or p.size,
    BORDER = selected and p.selectedBorder or p.border,
    ON_CLICK = p.onClick,
    BORDER_COLOR = Component.color(selected and "gold" or "brassDim"),
    HP_BORDER_COLOR = Component.color(low and "hostileRed" or "brass"),
    HP_COLOR = Component.color(low and "warmOrange" or "textCream"),
  })
end

return PortraitButton
