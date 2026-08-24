-- Tонкий entrypoint: инициализирует слои и проксирует глобальные TTS-колбэки.
local PartyService = require("core.PartyService")
local HUDEvents = require("ui.HUDEvents")
local HUDView = require("ui.HUDView")

function onLoad(saved_data)
  -- Восстанавливаем данные: сначала пробуем script_state, потом Notebook
  local data = saved_data
  if data == nil or data == "" then
    -- Fallback: читаем из Notebook (переживает push через tts_bridge)
    for _, tab in ipairs(Notes.getNotebookTabs()) do
      if tab.title == "KVS_DATA" then
        data = tab.body or ""
        break
      end
    end
  end
  if data ~= nil and data ~= "" then
    local ok, decoded = pcall(JSON.decode, data)
    if ok and type(decoded) == "table" then
      _G.kvs_storage = decoded
      print("[KVS] Restored " .. tostring(#(decoded.partyIds or {})) .. " characters")
    end
  end
  HUDView.mount()
  PartyService.load(function()
    HUDView.renderNow()
  end)
end

function onSave()
  -- Сохраняем в script_state И в Notebook (для надёжности при hot-reload)
  if _G.kvs_storage ~= nil then
    local data = JSON.encode(_G.kvs_storage)
    -- Notebook: создаём или обновляем вкладку KVS_DATA
    local found = false
    for _, tab in ipairs(Notes.getNotebookTabs()) do
      if tab.title == "KVS_DATA" then
        Notes.editNotebookTab({ index = tab.index, body = data })
        found = true
        break
      end
    end
    if not found then
      Notes.addNotebookTab({ title = "KVS_DATA", body = data, color = "Grey" })
    end
    return data
  end
  return ""
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
