-- Единственное место, где UI-события (клики из XML) превращаются в вызовы
-- сервисов core/. Ничего здесь не мутирует состояние и не рендерит —
-- только парсит id элемента и зовёт соответствующий метод PartyService.
-- Колбэки onClick из TTS UI обязаны быть глобальными функциями, поэтому
-- объявлены без `local`.
local PartyService = require("core.PartyService")

function HUD_onPortraitClick(player, _value, id)
  local characterId = id:gsub("^portrait_", "")
  PartyService.selectCharacter(player.color, characterId)
end

function CharacterSheet_onOpenClick(player, _value, _id)
  PartyService.openCharacterSheet(player.color)
end

function CharacterPanel_onClose(_player, _value, _id)
  PartyService.closeCharacterSheet()
end

function CharacterPanel_onTabClick(_player, _value, id)
  local tabId = id:gsub("^tab_", "")
  PartyService.setActiveTab(tabId)
end

function Hotbar_onAbilityClick(_player, _value, id)
  local abilityId = id:gsub("^hotbar_", "")
  PartyService.useAbility(abilityId)
end
