-- Персистенция через Bag: на столе живёт бэг "KVS Персонажи" (тег kvs_bag).
-- Каждый персонаж = BlockSquare внутри бэга с данными в script_state.
-- Объекты в бэге переживают любой reload/push/сохранение.
local PersistenceService = {}

local ModelTemplates = require("core.ModelTemplates")
local ModelValidators = require("core.ModelValidators")

local BAG_TAG = "kvs_bag"
local CHAR_TAG = "kvs_char"

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
    _G.kvs_storage = { charactersById = {}, partyIds = {} }
  end
  if _G.kvs_storage.charactersById == nil then
    _G.kvs_storage.charactersById = {}
  end
  if _G.kvs_storage.partyIds == nil then
    _G.kvs_storage.partyIds = {}
  end
end

-- Находит или создаёт бэг для персонажей.
local function getOrCreateBag()
  local bags = getObjectsWithTag(BAG_TAG)
  if #bags > 0 then
    return bags[1]
  end
  -- Бэга нет — спавним
  local bag = spawnObject({
    type = "Bag",
    position = { -15, 1.5, 0 },
    sound = false,
    callback_function = function(obj)
      obj.addTag(BAG_TAG)
      obj.setName("KVS Персонажи")
      obj.setLock(true)
      obj.setDescription("Хранилище персонажей КВС. Не удалять.")
    end
  })
  return bag
end

-- Загружает персонажей из содержимого бэга в память.
local function loadFromBag()
  ensureStorage()
  local bags = getObjectsWithTag(BAG_TAG)
  if #bags == 0 then return end
  local bag = bags[1]

  local contents = bag.getObjects()
  if contents == nil or #contents == 0 then return end

  local charactersById = {}
  local partyIds = {}
  for _, entry in ipairs(contents) do
    -- entry.lua_script_state содержит script_state объекта внутри бэга
    local data = entry.lua_script_state or ""
    if data ~= "" then
      local ok, decoded = pcall(JSON.decode, data)
      if ok and type(decoded) == "table" then
        local character = ModelTemplates.newCharacter(decoded)
        charactersById[character.id] = character
        table.insert(partyIds, character.id)
      end
    end
  end

  if next(charactersById) ~= nil then
    _G.kvs_storage.charactersById = charactersById
    _G.kvs_storage.partyIds = partyIds
  end
end

-- Кладёт новый объект-персонаж в бэг.
local function putCharacterInBag(character)
  local bag = getOrCreateBag()
  if bag == nil then return end

  local portrait = character.portrait or ""
  local objData = {
    Name = "Custom_Token",
    Transform = { posX = 0, posY = 5, posZ = 0, rotX = 0, rotY = 0, rotZ = 0, scaleX = 1, scaleY = 1, scaleZ = 1 },
    Nickname = character.name or "Character",
    Description = character.id,
    Tags = { CHAR_TAG },
    LuaScriptState = JSON.encode(character),
    CustomImage = {
      ImageURL = portrait ~= "" and portrait or "https://i.imgur.com/VpZqOFC.png",
      ImageSecondaryURL = portrait ~= "" and portrait or "https://i.imgur.com/VpZqOFC.png",
      CustomToken = { Thickness = 0.1 },
    },
  }
  spawnObjectJSON({
    json = JSON.encode(objData),
    callback_function = function(obj)
      bag.putObject(obj)
    end
  })
end

-- Обновляет объект персонажа в бэге (вытащить → обновить → положить).
local function updateCharacterInBag(character)
  local bags = getObjectsWithTag(BAG_TAG)
  if #bags == 0 then return end
  local bag = bags[1]

  local contents = bag.getObjects()
  for _, entry in ipairs(contents or {}) do
    if entry.description == character.id then
      -- Нашли — достаём, обновляем, кладём обратно
      bag.takeObject({
        guid = entry.guid,
        position = { 0, 10, 0 },
        smooth = false,
        callback_function = function(obj)
          obj.setName(character.name or "Character")
          obj.script_state = JSON.encode(character)
          -- Обновляем портрет на токене
          local portrait = character.portrait or ""
          if portrait ~= "" then
            obj.setCustomObject({ image = portrait, image_secondary = portrait })
          end
          Wait.frames(function()
            bag.putObject(obj)
          end, 2)
        end
      })
      return
    end
  end
  -- Не нашли — создаём новый
  putCharacterInBag(character)
end

-- Удаляет объект персонажа из бэга.
local function removeCharacterFromBag(characterId)
  local bags = getObjectsWithTag(BAG_TAG)
  if #bags == 0 then return end
  local bag = bags[1]

  local contents = bag.getObjects()
  for _, entry in ipairs(contents or {}) do
    if entry.description == characterId then
      bag.takeObject({
        guid = entry.guid,
        position = { 0, 10, 0 },
        smooth = false,
        callback_function = function(obj)
          destroyObject(obj)
        end
      })
      return
    end
  end
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

----------------------------------------------------------------- API --

function PersistenceService.loadParty(callback)
  ensureStorage()
  loadFromBag()
  callback(partyFromStorage())
end

function PersistenceService.getParty()
  ensureStorage()
  return partyFromStorage()
end

function PersistenceService.getCharacter(characterId)
  ensureStorage()
  local character = _G.kvs_storage.charactersById[characterId]
  if character == nil then return nil end
  return deepcopy(character)
end

function PersistenceService.createCharacter(partialCharacter, addToParty)
  ensureStorage()
  local character = ModelTemplates.newCharacter(partialCharacter)
  local ok, err = ModelValidators.validateCharacter(character)
  if not ok then return false, err end

  if _G.kvs_storage.charactersById[character.id] ~= nil then
    return false, "character id already exists: " .. character.id
  end

  _G.kvs_storage.charactersById[character.id] = character
  if addToParty ~= false then
    table.insert(_G.kvs_storage.partyIds, character.id)
  end
  putCharacterInBag(character)
  return true, character.id
end

function PersistenceService.updateCharacter(character)
  ensureStorage()
  if type(character) ~= "table" or type(character.id) ~= "string" or character.id == "" then
    return false, "updateCharacter ожидает character с id"
  end
  if _G.kvs_storage.charactersById[character.id] == nil then
    return false, "character not found: " .. character.id
  end

  local normalized = ModelTemplates.newCharacter(character)
  normalized.id = character.id
  local ok, err = ModelValidators.validateCharacter(normalized)
  if not ok then return false, err end

  -- Только в память — в бэг пишем при saveCharacterToBag (finishWizard)
  _G.kvs_storage.charactersById[normalized.id] = normalized
  return true, nil
end

-- Явное сохранение в бэг — вызывается из finishWizard, не на каждый keystroke.
function PersistenceService.saveCharacterToBag(characterId)
  ensureStorage()
  local character = _G.kvs_storage.charactersById[characterId]
  if character == nil then return end
  updateCharacterInBag(character)
end

function PersistenceService.removeCharacter(characterId)
  ensureStorage()
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
  removeCharacterFromBag(characterId)
  return true, nil
end

-- Спавнит видимую пешку (Custom Figurine) с silhouette.
function PersistenceService.deployPawn(characterId)
  ensureStorage()
  local character = _G.kvs_storage.charactersById[characterId]
  if character == nil then return false, "character not found" end

  local silhouette = character.silhouette or ""
  if silhouette == "" then
    return false, "Силуэт не задан — вставь URL в поле силуэта"
  end

  local objectData = {
    Name = "Figurine_Custom",
    Transform = {
      posX = 0, posY = 2, posZ = 0,
      rotX = 0, rotY = 180, rotZ = 0,
      scaleX = 1, scaleY = 1, scaleZ = 1,
    },
    Nickname = character.name or "Pawn",
    CustomImage = {
      ImageURL = silhouette,
      ImageSecondaryURL = silhouette,
    },
  }
  spawnObjectJSON({ json = JSON.encode(objectData) })
  return true, nil
end

return PersistenceService
