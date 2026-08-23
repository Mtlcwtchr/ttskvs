-- Точка входа для TTS onClick/onEndEdit: переводит событие в намерение сервиса.
local PartyService = require("core.PartyService")

local HUDEvents = {}

function HUDEvents.selectCharacter(_player, _value, id)
  PartyService.selectCharacter(id)
end

function HUDEvents.createCharacter()
  PartyService.createCharacter()
end

function HUDEvents.startWizard()
  PartyService.startWizard()
end

function HUDEvents.finishWizard()
  PartyService.finishWizard()
end

function HUDEvents.closeSheet()
  PartyService.closeSheet()
end

function HUDEvents.deleteCharacter()
  PartyService.deleteCharacter()
end

function HUDEvents.onCharacterFieldChanged(_player, value, id)
  PartyService.updateCharacterField(id, value)
end

return HUDEvents
