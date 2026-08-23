local PersistenceService = {}

local ModelTemplates = require("core.ModelTemplates")
local ModelValidators = require("core.ModelValidators")

local function deepcopy(value)
  if type(value) ~= "table" then
    return value
  end
  local out = {}
  for k, v in pairs(value) do
    out[k] = deepcopy(v)
  end
  return out
end

local function ensureStorage()
  if _G.kvs_storage == nil then
    _G.kvs_storage = ModelTemplates.newCharacterStorage()
  end

  if _G.kvs_storage.charactersById == nil then
    _G.kvs_storage.charactersById = {}
  end
  if _G.kvs_storage.partyIds == nil then
    _G.kvs_storage.partyIds = {}
  end
end

local function migrateLegacyParty()
  if type(_G.kvs_party) ~= "table" or #_G.kvs_party == 0 then
    return
  end
  for _, rawCharacter in ipairs(_G.kvs_party) do
    local character = ModelTemplates.newCharacter(rawCharacter)
    _G.kvs_storage.charactersById[character.id] = character
    table.insert(_G.kvs_storage.partyIds, character.id)
  end
  _G.kvs_party = nil
end

local function normalizeStorage()
  ensureStorage()
  migrateLegacyParty()

  local normalizedCharactersById = {}
  for id, rawCharacter in pairs(_G.kvs_storage.charactersById) do
    local character = ModelTemplates.newCharacter(rawCharacter)
    character.id = id
    normalizedCharactersById[id] = character
  end

  local normalizedPartyIds = {}
  local seen = {}
  for _, id in ipairs(_G.kvs_storage.partyIds) do
    if normalizedCharactersById[id] ~= nil and not seen[id] then
      table.insert(normalizedPartyIds, id)
      seen[id] = true
    end
  end

  _G.kvs_storage = {
    charactersById = normalizedCharactersById,
    partyIds = normalizedPartyIds,
  }
end

local function validateStorageOrReset()
  local ok, err = ModelValidators.validateStorage(_G.kvs_storage)
  if ok then
    return true
  end
  printToAll("[PersistenceService] Некорректное хранилище, сброс: " .. tostring(err), { 1, 0.3, 0.3 })
  _G.kvs_storage = ModelTemplates.newCharacterStorage()
  return false
end

local function partyFromStorage()
  local party = {}
  for _, id in ipairs(_G.kvs_storage.partyIds) do
    local character = _G.kvs_storage.charactersById[id]
    if character ~= nil then
      table.insert(party, deepcopy(character))
    end
  end
  return party
end

function PersistenceService.loadParty(callback)
  normalizeStorage()
  validateStorageOrReset()
  callback(partyFromStorage())
end

function PersistenceService.getParty()
  ensureStorage()
  return partyFromStorage()
end

function PersistenceService.getCharacter(characterId)
  ensureStorage()
  local character = _G.kvs_storage.charactersById[characterId]
  if character == nil then
    return nil
  end
  return deepcopy(character)
end

function PersistenceService.createCharacter(partialCharacter, addToParty)
  normalizeStorage()
  local character = ModelTemplates.newCharacter(partialCharacter)
  local ok, err = ModelValidators.validateCharacter(character)
  if not ok then
    return false, err
  end
  if _G.kvs_storage.charactersById[character.id] ~= nil then
    return false, "character id already exists: " .. character.id
  end

  _G.kvs_storage.charactersById[character.id] = character
  if addToParty ~= false then
    table.insert(_G.kvs_storage.partyIds, character.id)
  end
  validateStorageOrReset()
  return true, character.id
end

function PersistenceService.updateCharacter(character)
  normalizeStorage()
  if type(character) ~= "table" or type(character.id) ~= "string" or character.id == "" then
    return false, "updateCharacter ожидает character с id"
  end
  if _G.kvs_storage.charactersById[character.id] == nil then
    return false, "character not found: " .. character.id
  end

  local normalized = ModelTemplates.newCharacter(character)
  normalized.id = character.id
  local ok, err = ModelValidators.validateCharacter(normalized)
  if not ok then
    return false, err
  end

  _G.kvs_storage.charactersById[normalized.id] = normalized
  validateStorageOrReset()
  return true, nil
end

function PersistenceService.removeCharacter(characterId)
  normalizeStorage()
  if _G.kvs_storage.charactersById[characterId] == nil then
    return false, "character not found: " .. tostring(characterId)
  end

  _G.kvs_storage.charactersById[characterId] = nil
  local filtered = {}
  for _, id in ipairs(_G.kvs_storage.partyIds) do
    if id ~= characterId then
      table.insert(filtered, id)
    end
  end
  _G.kvs_storage.partyIds = filtered
  validateStorageOrReset()
  return true, nil
end

return PersistenceService
