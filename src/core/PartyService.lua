-- Централизованный сервис UI-состояния и операций над партией/персонажем.
-- Global.lua только проксирует события TTS сюда.
local CharacterFields = require("core.CharacterFields")
local PersistenceService = require("core.PersistenceService")
local Store = require("core.Store")

local SHEET_VIEW = "view"
local SHEET_WIZARD = "wizard"

local store = Store.new({
  party = {},
  selectedCharacterId = nil,
  sheetVisible = false,
  sheetMode = SHEET_VIEW,
})

local PartyService = {}

local function findById(characters, id)
  for _, character in ipairs(characters or {}) do
    if character.id == id then
      return character
    end
  end
  return nil
end

local function currentState()
  return store:getState()
end

local function decodeXmlEntities(raw)
  local s = tostring(raw or "")
  for _ = 1, 3 do
    local prev = s
    s = s:gsub("&lt;", "<")
      :gsub("&gt;", ">")
      :gsub("&quot;", "\"")
      :gsub("&apos;", "'")
      :gsub("&amp;", "&")
    if s == prev then
      break
    end
  end
  return s
end

local function refreshParty()
  local state = currentState()
  local party = PersistenceService.getParty()
  local selectedCharacterId = state.selectedCharacterId
  local sheetVisible = state.sheetVisible
  local sheetMode = state.sheetMode

  if selectedCharacterId ~= nil and findById(party, selectedCharacterId) == nil then
    selectedCharacterId = nil
    sheetVisible = false
    sheetMode = SHEET_VIEW
  end

  store:setState({
    party = party,
    selectedCharacterId = selectedCharacterId,
    sheetVisible = sheetVisible,
    sheetMode = sheetMode,
  })
end

function PartyService.subscribe(listener)
  store:subscribe(listener)
end

function PartyService.getState()
  return currentState()
end

function PartyService.load(onLoaded)
  PersistenceService.loadParty(function(loadedParty)
    local selectedCharacterId = nil
    if #loadedParty > 0 then
      selectedCharacterId = loadedParty[1].id
    end
    store:setState({
      party = loadedParty,
      selectedCharacterId = selectedCharacterId,
      sheetVisible = false,
      sheetMode = SHEET_VIEW,
    })
    if onLoaded ~= nil then
      onLoaded(currentState())
    end
  end)
end

function PartyService.selectCharacter(rawId)
  local characterId = tostring(rawId or ""):gsub("^character_", "")
  if characterId == "" then
    printToAll("[Character] Пустой id персонажа в selectCharacter", { 1, 0.3, 0.3 })
    return
  end
  local state = currentState()
  if findById(state.party, characterId) == nil then
    printToAll("[Character] Персонаж не найден в партии: " .. tostring(characterId), { 1, 0.3, 0.3 })
    return
  end
  store:setState({
    selectedCharacterId = characterId,
    sheetVisible = true,
    sheetMode = SHEET_VIEW,
  })
end

function PartyService.createCharacter()
  local ok, characterIdOrError = PersistenceService.createCharacter({}, true)
  if not ok then
    printToAll("[Character] Не удалось создать персонажа: " .. tostring(characterIdOrError), { 1, 0.3, 0.3 })
    return
  end
  store:setState({
    selectedCharacterId = characterIdOrError,
    sheetVisible = true,
    sheetMode = SHEET_WIZARD,
  })
  refreshParty()
end

function PartyService.startWizard()
  local state = currentState()
  if state.selectedCharacterId == nil then
    printToAll("[Character] Нельзя открыть редактор: персонаж не выбран", { 1, 0.8, 0.3 })
    return
  end
  store:setState({ sheetMode = SHEET_WIZARD })
end

function PartyService.finishWizard()
  local state = currentState()
  if state.selectedCharacterId == nil then
    printToAll("[Character] Нельзя завершить редактор: персонаж не выбран", { 1, 0.8, 0.3 })
    return
  end
  -- Обновляем партию и переключаем режим одним setState — один ре-рендер.
  local party = PersistenceService.getParty()
  store:setState({ party = party, sheetMode = SHEET_VIEW })
end

function PartyService.closeSheet()
  store:setState({
    sheetVisible = false,
    sheetMode = SHEET_VIEW,
  })
end

function PartyService.deleteCharacter()
  local state = currentState()
  if state.selectedCharacterId == nil then
    printToAll("[Character] Нельзя удалить: персонаж не выбран", { 1, 0.8, 0.3 })
    return
  end

  local ok, err = PersistenceService.removeCharacter(state.selectedCharacterId)
  if not ok then
    printToAll("[Character] Не удалось удалить персонажа: " .. tostring(err), { 1, 0.3, 0.3 })
    return
  end

  local party = PersistenceService.getParty()
  local selectedCharacterId = nil
  if #party > 0 then
    selectedCharacterId = party[1].id
  end
  store:setState({
    party = party,
    selectedCharacterId = selectedCharacterId,
    sheetVisible = false,
    sheetMode = SHEET_VIEW,
  })
end

function PartyService.updateCharacterField(fieldId, value)
  local state = currentState()
  if state.selectedCharacterId == nil then
    printToAll("[Character] Нельзя сохранить поле: персонаж не выбран", { 1, 0.8, 0.3 })
    return
  end

  local character = PersistenceService.getCharacter(state.selectedCharacterId)
  if character == nil then
    printToAll("[Character] Персонаж не найден: " .. tostring(state.selectedCharacterId), { 1, 0.3, 0.3 })
    return
  end

  local normalizedValue = decodeXmlEntities(value)
  if not CharacterFields.set(character, fieldId, normalizedValue) then
    printToAll("[Character] Неизвестное поле листа: " .. tostring(fieldId), { 1, 0.8, 0.3 })
    return
  end

  local ok, err = PersistenceService.updateCharacter(character)
  if not ok then
    printToAll("[Character] Не удалось сохранить поле: " .. tostring(err), { 1, 0.3, 0.3 })
    return
  end

  -- В режиме визарда не перерисовываем весь UI после каждого нажатия клавиши:
  -- InputField уже отображает актуальное значение (TTS держит его в своём
  -- состоянии), а перерисовка сбрасывала бы фокус и видимый текст.
  -- Единый ре-рендер произойдёт на finishWizard.
  if state.sheetMode ~= SHEET_WIZARD then
    refreshParty()
  end
end

-- Переключить владение навыком (клик по точке в списке навыков).
function PartyService.toggleSkillProficiency(skillKey)
  local state = currentState()
  if state.selectedCharacterId == nil then return end

  local character = PersistenceService.getCharacter(state.selectedCharacterId)
  if character == nil then return end

  local skills = character.proficientSkills or {}
  local found = false
  local newSkills = {}
  for _, key in ipairs(skills) do
    if tostring(key):lower() == skillKey then
      found = true
    else
      table.insert(newSkills, key)
    end
  end
  if not found then
    table.insert(newSkills, skillKey)
  end
  character.proficientSkills = newSkills
  PersistenceService.updateCharacter(character)
  refreshParty()
end

-- Переключить владение спасброском.
function PartyService.toggleSaveProficiency(ability)
  local state = currentState()
  if state.selectedCharacterId == nil then return end

  local character = PersistenceService.getCharacter(state.selectedCharacterId)
  if character == nil then return end

  local saves = character.savingThrowProficiencies or {}
  local found = false
  local newSaves = {}
  for _, key in ipairs(saves) do
    if key == ability then
      found = true
    else
      table.insert(newSaves, key)
    end
  end
  if not found then
    table.insert(newSaves, ability)
  end
  character.savingThrowProficiencies = newSaves
  PersistenceService.updateCharacter(character)
  refreshParty()
end

return PartyService
