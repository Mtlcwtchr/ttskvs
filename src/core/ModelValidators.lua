local ModelValidators = {}

local REQUIRED_ABILITY_KEYS = { "STR", "DEX", "CON", "INT", "WIS", "CHA" }

local function isNumber(value)
  return type(value) == "number"
end

local function isString(value)
  return type(value) == "string"
end

local function validateAbilityScores(scores)
  if type(scores) ~= "table" then
    return false, "abilityScores должен быть таблицей"
  end
  for _, key in ipairs(REQUIRED_ABILITY_KEYS) do
    if not isNumber(scores[key]) then
      return false, "abilityScores." .. key .. " должен быть числом"
    end
  end
  return true, nil
end

local function validateEquipment(item)
  if type(item) ~= "table" then
    return false, "equipment item должен быть таблицей"
  end
  if not isString(item.slot) or item.slot == "" then
    return false, "equipment.slot обязателен"
  end
  if item.name ~= nil and not isString(item.name) then
    return false, "equipment.name должен быть строкой"
  end
  return true, nil
end

local function validateWeapon(item)
  if type(item) ~= "table" then
    return false, "weapon должен быть таблицей"
  end
  if item.name ~= nil and not isString(item.name) then
    return false, "weapon.name должен быть строкой"
  end
  return true, nil
end

local function validateAbility(item)
  if type(item) ~= "table" then
    return false, "ability должен быть таблицей"
  end
  if item.name ~= nil and not isString(item.name) then
    return false, "ability.name должен быть строкой"
  end
  if item.actionType ~= nil and not isString(item.actionType) then
    return false, "ability.actionType должен быть строкой"
  end
  return true, nil
end

function ModelValidators.validateCharacter(character)
  if type(character) ~= "table" then
    return false, "character должен быть таблицей"
  end
  if not isString(character.id) or character.id == "" then
    return false, "character.id обязателен"
  end
  if not isString(character.name) or character.name == "" then
    return false, "character.name обязателен"
  end
  if not isNumber(character.level) or character.level < 1 then
    return false, "character.level должен быть числом >= 1"
  end
  if type(character.hp) ~= "table" or not isNumber(character.hp.current) or not isNumber(character.hp.max) then
    return false, "character.hp должен иметь current/max"
  end
  local ok, err = validateAbilityScores(character.abilityScores)
  if not ok then
    return false, err
  end

  for index, equipment in ipairs(character.equipment or {}) do
    local eqOk, eqErr = validateEquipment(equipment)
    if not eqOk then
      return false, string.format("equipment[%d]: %s", index, eqErr)
    end
  end
  for index, weapon in ipairs(character.attacks or {}) do
    local wOk, wErr = validateWeapon(weapon)
    if not wOk then
      return false, string.format("attacks[%d]: %s", index, wErr)
    end
  end
  for index, ability in ipairs(character.abilities or {}) do
    local aOk, aErr = validateAbility(ability)
    if not aOk then
      return false, string.format("abilities[%d]: %s", index, aErr)
    end
  end

  return true, nil
end

function ModelValidators.validateParty(party)
  if type(party) ~= "table" then
    return false, "party должен быть массивом"
  end
  local ids = {}
  for index, character in ipairs(party) do
    local ok, err = ModelValidators.validateCharacter(character)
    if not ok then
      return false, string.format("party[%d]: %s", index, err)
    end
    if ids[character.id] then
      return false, "дублирующийся character.id: " .. character.id
    end
    ids[character.id] = true
  end
  return true, nil
end

function ModelValidators.validateStorage(storage)
  if type(storage) ~= "table" then
    return false, "storage должен быть таблицей"
  end
  if type(storage.charactersById) ~= "table" then
    return false, "storage.charactersById должен быть таблицей"
  end
  if type(storage.partyIds) ~= "table" then
    return false, "storage.partyIds должен быть массивом"
  end

  for id, character in pairs(storage.charactersById) do
    if type(id) ~= "string" or id == "" then
      return false, "storage.charactersById имеет невалидный ключ"
    end
    local ok, err = ModelValidators.validateCharacter(character)
    if not ok then
      return false, "storage.charactersById[" .. id .. "]: " .. err
    end
    if character.id ~= id then
      return false, "storage.charactersById[" .. id .. "] имеет несовпадающий character.id"
    end
  end

  for index, id in ipairs(storage.partyIds) do
    if type(id) ~= "string" or id == "" then
      return false, string.format("storage.partyIds[%d] должен быть строкой", index)
    end
    if storage.charactersById[id] == nil then
      return false, "storage.partyIds содержит неизвестный id: " .. id
    end
  end

  return true, nil
end

return ModelValidators
