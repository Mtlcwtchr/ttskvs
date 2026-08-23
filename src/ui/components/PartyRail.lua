-- Рейка партии. Портреты — цикл по контексту рендера: длину списка разметка
-- знать не может, поэтому это единственный слот в PartyRail.xml.
local Component = require("ui.Component")
local Markup = require("ui.Markup")
local PortraitButton = require("ui.components.PortraitButton")
local Templates = require("ui.generated.Templates")

local PartyRail = {}

PartyRail.defaults = {
  width = 140,
  height = 800,
  color = "railBg",
}

-- Строка в Lua — байты: name:sub(1, 1) от «Мира» вернул бы половину буквы и
-- сделал бы весь XML невалидным UTF-8 (уже наступали).
local function firstCharacter(text)
  local s = tostring(text or "")
  if s == "" then
    return "?"
  end
  return s:match("^[\1-\127\194-\244][\128-\191]*") or s:sub(1, 1)
end

function PartyRail.render(props)
  local p = Component.props(PartyRail.defaults, props)
  local context = Markup.context()
  local portraits = {}

  for _, character in ipairs(context.party or {}) do
    local hp = character.hp or {}
    table.insert(portraits, PortraitButton.render({
      characterId = character.id,
      initial = Component.escape(firstCharacter(character.name)),
      hp = string.format("%d/%d", hp.current or 0, hp.max or 0),
      selected = character.id == context.selectedCharacterId,
    }))
  end

  return Component.render(Templates.PartyRail, {
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    PORTRAITS = Component.join(portraits),
  })
end

return PartyRail
