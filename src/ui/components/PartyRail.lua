-- Рейка партии. Портреты — цикл по контексту рендера: длину списка разметка
-- знать не может, поэтому это единственный слот в PartyRail.xml. Размер рейки
-- задаёт <Anchor> в MainUI.xml, здесь только цвет, отступы и данные.
local Component = require("ui.Component")
local Markup = require("ui.Markup")
local PortraitButton = require("ui.components.PortraitButton")
local Templates = require("ui.generated.Templates")

local PartyRail = {}

PartyRail.defaults = {
  color = "railBg",
  seatSize = 72,
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
    local current, max = hp.current or 0, hp.max or 0
    local portraitUrl = character.portrait or ""
    table.insert(portraits, PortraitButton.render({
      characterId = character.id,
      initial = Component.escape(firstCharacter(character.name)),
      portraitImage = portraitUrl ~= "" and ("portrait_" .. character.id) or "",
      hp = string.format("%d/%d", current, max),
      hpLow = max > 0 and (current / max) <= 0.5,
      selected = character.id == context.selectedCharacterId,
    }))
  end

  return Component.render(Templates.PartyRail, {
    COLOR = Component.color(p.color),
    SEAT_SIZE = p.seatSize,
    PORTRAITS = Component.join(portraits),
  })
end

return PartyRail
