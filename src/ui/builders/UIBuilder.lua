local UIBuilder = {}

local function replaceAll(template, replacements)
  local result = template
  for key, value in pairs(replacements) do
    result = result:gsub("{{" .. key .. "}}", value or "")
  end
  return result
end

function UIBuilder.buildPortrait(character, isSelected)
  local portraitTemplate = require("ui.templates.PortraitButton")
  local borderColor = isSelected and "#e6cd85" or "#7f7752"
  local bgColor = isSelected and "rgba(0.231, 0.318, 0.176, 0.8)" or "rgba(0.141, 0.141, 0.110, 0.8)"
  local hp = character.hp or {}
  local hpText = string.format("%d/%d", hp.current or 0, hp.max or 0)

  return replaceAll(portraitTemplate, {
    CHARACTER_ID = character.id,
    BORDER_COLOR = borderColor,
    BG_COLOR = bgColor,
    INITIAL = (character.name or "?"):sub(1, 1),
    HP = hpText,
  })
end

function UIBuilder.buildPartyHUD(party, selectedCharacterId)
  local portraitsTemplate = require("ui.templates.PartyPortraits")
  local addTemplate = require("ui.templates.AddCharacterButton")
  local buttons = {}

  for _, character in ipairs(party) do
    local isSelected = character.id == selectedCharacterId
    table.insert(buttons, UIBuilder.buildPortrait(character, isSelected))
  end

  return replaceAll(portraitsTemplate, {
    PORTRAIT_BUTTONS = table.concat(buttons),
    ADD_BUTTON = addTemplate,
  })
end

function UIBuilder.buildCharacterSheet(character)
  if not character then
    return ""
  end
  local renderer = require("ui.builders.CharacterSheetRenderer")
  return renderer.render(character)
end

function UIBuilder.buildMainUI(party, selectedCharacterId, sheetVisible)
  local mainTemplate = require("ui.templates.MainUI")
  local partyHUD = UIBuilder.buildPartyHUD(party, selectedCharacterId)
  local characterSheet = ""

  if sheetVisible and selectedCharacterId then
    for _, character in ipairs(party) do
      if character.id == selectedCharacterId then
        characterSheet = UIBuilder.buildCharacterSheet(character)
        break
      end
    end
  end

  return replaceAll(mainTemplate, {
    PARTY_PORTRAITS = partyHUD,
    CHARACTER_SHEET = characterSheet,
  })
end

return UIBuilder
