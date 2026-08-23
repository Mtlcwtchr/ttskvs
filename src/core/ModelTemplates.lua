local ModelTemplates = {}

local EQUIPMENT_SLOTS = {
  "helm", "amulet", "charm", "cloak", "mail", "glove", "belt", "ring1", "ring2", "boot",
}

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

local function defaultEquipment(slot)
  return {
    slot = slot,
    itemId = "",
    name = "",
  }
end

local function defaultWeapon()
  return {
    id = "",
    name = "",
    atkBonus = "",
    damage = "",
    damageType = "",
    range = "",
  }
end

local function defaultAbility()
  return {
    id = "",
    name = "",
    actionType = "action",
    description = "",
    uses = { current = 0, max = 0 },
  }
end

local function defaultCharacter()
  local equipment = {}
  for _, slot in ipairs(EQUIPMENT_SLOTS) do
    table.insert(equipment, defaultEquipment(slot))
  end

  return {
    id = "",
    name = "Новый герой",
    portrait = "",
    playerName = "",
    race = "",
    class = "",
    level = 1,
    background = "",
    alignment = "",
    experience = { current = 0, next = 300 },
    hp = { current = 10, max = 10, temp = 0 },
    speed = 30,
    hitDice = "1d8",
    deathSaves = { successes = 0, failures = 0 },
    abilityScores = {
      STR = 10, DEX = 10, CON = 10, INT = 10, WIS = 10, CHA = 10,
    },
    proficiencyBonus = 2,
    inspiration = false,
    savingThrowProficiencies = {},
    proficientSkills = {},
    combat = { armorClass = 10, meleeBonus = 0, rangedBonus = 0 },
    attacks = { defaultWeapon() },
    carryWeight = { current = 0, max = 0 },
    attunement = { used = 0, max = 3 },
    equipment = equipment,
    resources = {
      stamina = { current = 0, max = 0 },
      mana = { current = 0, max = 0 },
    },
    spellSlots = {},
    abilities = { defaultAbility() },
    inventory = {},
    otherProficiencies = {},
    personality = {
      traits = "",
      ideals = "",
      bonds = "",
      flaws = "",
    },
  }
end

local function nextCharacterId()
  local millis = math.floor((os.time() or 0) * 1000)
  local suffix = math.random(1000, 9999)
  return string.format("char_%d_%d", millis, suffix)
end

local function merge(base, patch)
  local out = deepcopy(base)
  for key, value in pairs(patch or {}) do
    if type(value) == "table" and type(out[key]) == "table" then
      out[key] = merge(out[key], value)
    else
      out[key] = deepcopy(value)
    end
  end
  return out
end

function ModelTemplates.newEquipment(partial)
  return merge(defaultEquipment((partial or {}).slot or ""), partial or {})
end

function ModelTemplates.newWeapon(partial)
  return merge(defaultWeapon(), partial or {})
end

function ModelTemplates.newAbility(partial)
  return merge(defaultAbility(), partial or {})
end

function ModelTemplates.newCharacter(partial)
  local character = merge(defaultCharacter(), partial or {})
  if character.id == nil or character.id == "" then
    character.id = nextCharacterId()
  end

  local normalizedEquipment = {}
  local bySlot = {}
  for _, item in ipairs(character.equipment or {}) do
    if type(item) == "table" and type(item.slot) == "string" and item.slot ~= "" then
      bySlot[item.slot] = ModelTemplates.newEquipment(item)
    end
  end
  for _, slot in ipairs(EQUIPMENT_SLOTS) do
    table.insert(normalizedEquipment, bySlot[slot] or defaultEquipment(slot))
  end
  character.equipment = normalizedEquipment

  local attacks = {}
  for _, item in ipairs(character.attacks or {}) do
    table.insert(attacks, ModelTemplates.newWeapon(item))
  end
  if #attacks == 0 then
    table.insert(attacks, defaultWeapon())
  end
  character.attacks = attacks

  local abilities = {}
  for _, item in ipairs(character.abilities or {}) do
    table.insert(abilities, ModelTemplates.newAbility(item))
  end
  if #abilities == 0 then
    table.insert(abilities, defaultAbility())
  end
  character.abilities = abilities

  return character
end

function ModelTemplates.newParty(partial)
  local out = {}
  for _, item in ipairs(partial or {}) do
    table.insert(out, ModelTemplates.newCharacter(item))
  end
  return out
end

function ModelTemplates.newCharacterStorage()
  return {
    charactersById = {},
    partyIds = {},
  }
end

return ModelTemplates
