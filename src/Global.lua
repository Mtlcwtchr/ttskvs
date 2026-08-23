local PersistenceService = require("core.PersistenceService")
local UIBuilder = require("ui.builders.UIBuilder")

local party = {}
local selectedCharacterId = nil
local sheetVisible = false

local function findById(characters, id)
  for _, character in ipairs(characters) do
    if character.id == id then
      return character
    end
  end
  return nil
end

local function renderUI()
  UI.setXml(UIBuilder.buildMainUI(party, selectedCharacterId, sheetVisible))
end

local function refreshParty()
  party = PersistenceService.getParty()
  if selectedCharacterId ~= nil and findById(party, selectedCharacterId) == nil then
    selectedCharacterId = nil
    sheetVisible = false
  end
end

local function parseInteger(raw, fallback)
  local n = tonumber(raw)
  if n == nil then
    return fallback
  end
  return math.floor(n)
end

local function parseCsv(raw)
  local out = {}
  local seen = {}
  for token in tostring(raw or ""):gmatch("([^,]+)") do
    local value = token:gsub("^%s+", ""):gsub("%s+$", "")
    if value ~= "" and not seen[value] then
      table.insert(out, value)
      seen[value] = true
    end
  end
  return out
end

local function ensureEquipmentSlot(character, slot)
  character.equipment = character.equipment or {}
  for _, item in ipairs(character.equipment) do
    if item.slot == slot then
      return item
    end
  end
  local item = { slot = slot, itemId = nil, name = "" }
  table.insert(character.equipment, item)
  return item
end

local function updateCharacterField(character, fieldId, value)
  if fieldId == "field_name" then
    character.name = value
    return true
  elseif fieldId == "field_race" then
    character.race = value
    return true
  elseif fieldId == "field_class" then
    character.class = value
    return true
  elseif fieldId == "field_level" then
    character.level = math.max(1, parseInteger(value, character.level or 1))
    return true
  elseif fieldId == "field_hp_current" then
    character.hp = character.hp or { current = 0, max = 0, temp = 0 }
    character.hp.current = math.max(0, parseInteger(value, character.hp.current or 0))
    return true
  elseif fieldId == "field_hp_max" then
    character.hp = character.hp or { current = 0, max = 0, temp = 0 }
    character.hp.max = math.max(1, parseInteger(value, character.hp.max or 1))
    if character.hp.current > character.hp.max then
      character.hp.current = character.hp.max
    end
    return true
  elseif fieldId == "field_speed" then
    character.speed = math.max(0, parseInteger(value, character.speed or 0))
    return true
  elseif fieldId == "field_background" then
    character.background = value
    return true
  elseif fieldId == "field_alignment" then
    character.alignment = value
    return true
  elseif fieldId == "field_skills_csv" then
    character.proficientSkills = parseCsv(value)
    return true
  elseif fieldId == "field_player_name" then
    character.playerName = value
    return true
  elseif fieldId:match("^field_ability_") then
    local key = fieldId:gsub("^field_ability_", "")
    character.abilityScores = character.abilityScores or {}
    character.abilityScores[key] = math.max(1, parseInteger(value, character.abilityScores[key] or 10))
    return true
  elseif fieldId:match("^field_equip_") then
    local slot = fieldId:gsub("^field_equip_", "")
    local equip = ensureEquipmentSlot(character, slot)
    equip.name = value
    return true
  elseif fieldId == "field_weapon_name" then
    character.attacks = character.attacks or {}
    if character.attacks[1] == nil then
      character.attacks[1] = { name = "", atkBonus = "", damage = "" }
    end
    character.attacks[1].name = value
    return true
  elseif fieldId == "field_weapon_bonus" then
    character.attacks = character.attacks or {}
    if character.attacks[1] == nil then
      character.attacks[1] = { name = "", atkBonus = "", damage = "" }
    end
    character.attacks[1].atkBonus = value
    return true
  elseif fieldId == "field_weapon_damage" then
    character.attacks = character.attacks or {}
    if character.attacks[1] == nil then
      character.attacks[1] = { name = "", atkBonus = "", damage = "" }
    end
    character.attacks[1].damage = value
    return true
  elseif fieldId == "field_ability_name" then
    character.abilities = character.abilities or {}
    if character.abilities[1] == nil then
      character.abilities[1] = { id = "ability_primary", name = "", actionType = "action", description = "" }
    end
    character.abilities[1].name = value
    return true
  elseif fieldId == "field_ability_type" then
    character.abilities = character.abilities or {}
    if character.abilities[1] == nil then
      character.abilities[1] = { id = "ability_primary", name = "", actionType = "action", description = "" }
    end
    character.abilities[1].actionType = value
    return true
  end
  return false
end

function onLoad()
  PersistenceService.loadParty(function(loadedParty)
    party = loadedParty
    if #party > 0 then
      selectedCharacterId = party[1].id
    end
    renderUI()
  end)
end

function selectCharacter(_player, _value, id)
  selectedCharacterId = id:gsub("^character_", "")
  sheetVisible = true
  renderUI()
end

function createCharacter()
  local ok, characterIdOrError = PersistenceService.createCharacter({}, true)
  if not ok then
    printToAll("[Character] Не удалось создать персонажа: " .. tostring(characterIdOrError), { 1, 0.3, 0.3 })
    return
  end
  selectedCharacterId = characterIdOrError
  sheetVisible = true
  refreshParty()
  renderUI()
end

function closeSheet()
  sheetVisible = false
  renderUI()
end

function deleteCharacter()
  if selectedCharacterId == nil then
    return
  end
  local removedId = selectedCharacterId
  local ok, err = PersistenceService.removeCharacter(removedId)
  if not ok then
    printToAll("[Character] Не удалось удалить персонажа: " .. tostring(err), { 1, 0.3, 0.3 })
    return
  end
  refreshParty()
  if #party > 0 then
    selectedCharacterId = party[1].id
  else
    selectedCharacterId = nil
    sheetVisible = false
  end
  renderUI()
end

function onCharacterFieldChanged(_player, value, id)
  if selectedCharacterId == nil then
    return
  end
  local character = PersistenceService.getCharacter(selectedCharacterId)
  if character == nil then
    return
  end
  local changed = updateCharacterField(character, id, value)
  if not changed then
    return
  end
  local ok, err = PersistenceService.updateCharacter(character)
  if not ok then
    printToAll("[Character] Не удалось сохранить поле: " .. tostring(err), { 1, 0.3, 0.3 })
    return
  end
  refreshParty()
  renderUI()
end