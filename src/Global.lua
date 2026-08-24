-- Tонкий entrypoint: инициализирует слои и проксирует глобальные TTS-колбэки.
local PartyService = require("core.PartyService")
local HUDEvents = require("ui.HUDEvents")
local HUDView = require("ui.HUDView")

function onLoad()
  HUDView.mount()
  -- Рисуем сразу (пустая party — но кнопка "+" видна)
  HUDView.renderNow()
  -- Через 5 фреймов подгружаем из бэга (теги объектов готовы не сразу)
  Wait.frames(function()
    PartyService.load(function()
      HUDView.renderNow()
    end)
  end, 5)
end

function selectCharacter(player, value, id)
  HUDEvents.selectCharacter(player, value, id)
end

function createCharacter(player, value, id)
  HUDEvents.createCharacter(player, value, id)
end

function startWizard(player, value, id)
  HUDEvents.startWizard(player, value, id)
end

function finishWizard(player, value, id)
  HUDEvents.finishWizard(player, value, id)
end

function closeSheet(player, value, id)
  HUDEvents.closeSheet(player, value, id)
end

function deleteCharacter(player, value, id)
  HUDEvents.deleteCharacter(player, value, id)
end

function deployPawn(player, value, id)
  HUDEvents.deployPawn(player, value, id)
end

function toggleSkill(player, value, id)
  HUDEvents.toggleSkill(player, value, id)
end

function toggleSave(player, value, id)
  HUDEvents.toggleSave(player, value, id)
end

function addNote(player, value, id)
  HUDEvents.addNote(player, value, id)
end

function deleteNote(player, value, id)
  HUDEvents.deleteNote(player, value, id)
end

function onCharacterFieldChanged(player, value, id)
  HUDEvents.onCharacterFieldChanged(player, value, id)
end
