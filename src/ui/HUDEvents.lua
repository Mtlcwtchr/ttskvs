-- Tочка входа для TTS onClick/onEndEdit: переводит событие в намерение сервиса.
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

function HUDEvents.toggleSkill(_player, _value, id)
  -- id = "skill_perception", "skill_arcana", etc.
  local key = id:match("^skill_(.+)$")
  if key then
    PartyService.toggleSkillProficiency(key)
  end
end

function HUDEvents.toggleSave(_player, _value, id)
  -- id = "save_STR", "save_DEX", etc.
  local ability = id:match("^save_(.+)$")
  if ability then
    PartyService.toggleSaveProficiency(ability)
  end
end

function HUDEvents.addNote()
  PartyService.addNote()
end

function HUDEvents.deleteNote(_player, _value, id)
  local index = tonumber(id:match("^delete_note_(%d+)$"))
  if index then
    PartyService.deleteNote(index)
  end
end

function HUDEvents.onCharacterFieldChanged(_player, value, id)
  PartyService.updateCharacterField(id, value)
end

return HUDEvents
