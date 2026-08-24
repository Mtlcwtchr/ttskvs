-- Единый реестр полей персонажа: id элемента UI -> как прочитать и как
-- записать значение в модель. Раньше это существовало в двух копиях — список
-- значений в рендерере листа и if-цепочка updateCharacterField в Global.lua —
-- и они разъезжались. Tеперь и лист, и обработчик правки ходят сюда.
--
-- Слой core: знает про модель персонажа и ничего не знает про XML/подписи —
-- подписи и порядок полей на листе живут в ui/builders (это лейаут, не модель).
local CharacterFields = {}

local function toInteger(raw, fallback)
  local n = tonumber(raw)
  if n == nil then
    return fallback
  end
  return math.floor(n)
end

local function clampInteger(raw, fallback, min)
  local n = toInteger(raw, fallback)
  if min ~= nil and n < min then
    return min
  end
  return n
end

local function splitCsv(raw)
  local out, seen = {}, {}
  for token in tostring(raw or ""):gmatch("([^,]+)") do
    local value = token:gsub("^%s+", ""):gsub("%s+$", "")
    if value ~= "" and not seen[value] then
      table.insert(out, value)
      seen[value] = true
    end
  end
  return out
end

local function joinCsv(list)
  return table.concat(list or {}, ", ")
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

-- Вложенные таблицы модели могут отсутствовать у персонажа, пришедшего из
-- старого сейва: доводим до формы по месту, а не падаем.
local function sub(character, key, defaults)
  if type(character[key]) ~= "table" then
    character[key] = {}
  end
  for k, v in pairs(defaults or {}) do
    if character[key][k] == nil then
      character[key][k] = v
    end
  end
  return character[key]
end

local function resources(character)
  local res = sub(character, "resources", {})
  if type(res.stamina) ~= "table" then res.stamina = { current = 0, max = 0 } end
  if type(res.mana) ~= "table" then res.mana = { current = 0, max = 0 } end
  return res
end

local function listEntry(character, key, index, template)
  if type(character[key]) ~= "table" then
    character[key] = {}
  end
  local list = character[key]
  for i = 1, index do
    if list[i] == nil then
      local blank = {}
      for k, v in pairs(template) do
        blank[k] = v
      end
      list[i] = blank
    end
  end
  return list[index]
end

local ATTACK_TEMPLATE = { id = "", name = "", atkBonus = "", damage = "", damageType = "", range = "" }
local ITEM_TEMPLATE = { itemId = "", name = "", qty = 1 }
local ABILITY_TEMPLATE = { id = "", name = "", actionType = "action", description = "" }
local CUSTOM_GROUP_TEMPLATE = { title = "", description = "" }

-- kind говорит UI, каким контролом рисовать поле в режиме визарда:
-- integer -> characterValidation="Integer", multiline -> lineType="MultiLine".
local SCALARS = {
  field_name = { kind = "text",
    get = function(c) return c.name or "" end,
    set = function(c, v) c.name = v end },
  field_race = { kind = "text",
    get = function(c) return c.race or "" end,
    set = function(c, v) c.race = v end },
  field_age = { kind = "text",
    get = function(c) return c.age or "" end,
    set = function(c, v) c.age = v end },
  field_class = { kind = "text",
    get = function(c) return c.class or "" end,
    set = function(c, v) c.class = v end },
  field_level = { kind = "integer",
    get = function(c) return c.level or 1 end,
    set = function(c, v) c.level = clampInteger(v, c.level or 1, 1) end },
  field_background = { kind = "text",
    get = function(c) return c.background or "" end,
    set = function(c, v) c.background = v end },
  field_alignment = { kind = "text",
    get = function(c) return c.alignment or "" end,
    set = function(c, v) c.alignment = v end },
  field_player_name = { kind = "text",
    get = function(c) return c.playerName or "" end,
    set = function(c, v) c.playerName = v end },

  field_xp_current = { kind = "integer",
    get = function(c) return sub(c, "experience", { current = 0, next = 300 }).current end,
    set = function(c, v) local e = sub(c, "experience", { current = 0, next = 300 })
      e.current = clampInteger(v, e.current, 0) end },
  field_xp_next = { kind = "integer",
    get = function(c) return sub(c, "experience", { current = 0, next = 300 }).next end,
    set = function(c, v) local e = sub(c, "experience", { current = 0, next = 300 })
      e.next = clampInteger(v, e.next, 0) end },
  field_proficiency_bonus = { kind = "integer",
    get = function(c) return c.proficiencyBonus or 2 end,
    set = function(c, v) c.proficiencyBonus = clampInteger(v, c.proficiencyBonus or 2, 0) end },

  field_hp_current = { kind = "integer",
    get = function(c) return sub(c, "hp", { current = 0, max = 1, temp = 0 }).current end,
    set = function(c, v) local hp = sub(c, "hp", { current = 0, max = 1, temp = 0 })
      hp.current = clampInteger(v, hp.current, 0) end },
  field_hp_max = { kind = "integer",
    get = function(c) return sub(c, "hp", { current = 0, max = 1, temp = 0 }).max end,
    set = function(c, v) local hp = sub(c, "hp", { current = 0, max = 1, temp = 0 })
      hp.max = clampInteger(v, hp.max, 1)
      if hp.current > hp.max then hp.current = hp.max end end },
  field_hp_temp = { kind = "integer",
    get = function(c) return sub(c, "hp", { current = 0, max = 1, temp = 0 }).temp or 0 end,
    set = function(c, v) local hp = sub(c, "hp", { current = 0, max = 1, temp = 0 })
      hp.temp = clampInteger(v, hp.temp or 0, 0) end },
  field_hit_dice = { kind = "text",
    get = function(c) return c.hitDice or "" end,
    set = function(c, v) c.hitDice = v end },
  field_speed = { kind = "integer",
    get = function(c) return c.speed or 0 end,
    set = function(c, v) c.speed = clampInteger(v, c.speed or 0, 0) end },

  field_stamina_current = { kind = "integer",
    get = function(c) return resources(c).stamina.current or 0 end,
    set = function(c, v) local s = resources(c).stamina
      s.current = clampInteger(v, s.current or 0, 0) end },
  field_stamina_max = { kind = "integer",
    get = function(c) return resources(c).stamina.max or 0 end,
    set = function(c, v) local s = resources(c).stamina
      s.max = clampInteger(v, s.max or 0, 0) end },
  field_mana_current = { kind = "integer",
    get = function(c) return resources(c).mana.current or 0 end,
    set = function(c, v) local m = resources(c).mana
      m.current = clampInteger(v, m.current or 0, 0) end },
  field_mana_max = { kind = "integer",
    get = function(c) return resources(c).mana.max or 0 end,
    set = function(c, v) local m = resources(c).mana
      m.max = clampInteger(v, m.max or 0, 0) end },

  field_armor_class = { kind = "integer",
    get = function(c) return sub(c, "combat", { armorClass = 10, meleeBonus = 0, rangedBonus = 0 }).armorClass end,
    set = function(c, v) local combat = sub(c, "combat", { armorClass = 10, meleeBonus = 0, rangedBonus = 0 })
      combat.armorClass = clampInteger(v, combat.armorClass, 0) end },
  field_melee_bonus = { kind = "integer",
    get = function(c) return sub(c, "combat", { armorClass = 10, meleeBonus = 0, rangedBonus = 0 }).meleeBonus end,
    set = function(c, v) local combat = sub(c, "combat", { armorClass = 10, meleeBonus = 0, rangedBonus = 0 })
      combat.meleeBonus = toInteger(v, combat.meleeBonus) end },
  field_ranged_bonus = { kind = "integer",
    get = function(c) return sub(c, "combat", { armorClass = 10, meleeBonus = 0, rangedBonus = 0 }).rangedBonus end,
    set = function(c, v) local combat = sub(c, "combat", { armorClass = 10, meleeBonus = 0, rangedBonus = 0 })
      combat.rangedBonus = toInteger(v, combat.rangedBonus) end },

  field_carry_current = { kind = "integer",
    get = function(c) return sub(c, "carryWeight", { current = 0, max = 0 }).current end,
    set = function(c, v) local w = sub(c, "carryWeight", { current = 0, max = 0 })
      w.current = clampInteger(v, w.current, 0) end },
  field_carry_max = { kind = "integer",
    get = function(c) return sub(c, "carryWeight", { current = 0, max = 0 }).max end,
    set = function(c, v) local w = sub(c, "carryWeight", { current = 0, max = 0 })
      w.max = clampInteger(v, w.max, 0) end },

  field_saves_csv = { kind = "csv",
    get = function(c) return joinCsv(c.savingThrowProficiencies) end,
    set = function(c, v) c.savingThrowProficiencies = splitCsv(v) end },
  field_skills_csv = { kind = "csv",
    get = function(c) return joinCsv(c.proficientSkills) end,
    set = function(c, v) c.proficientSkills = splitCsv(v) end },
  field_other_proficiencies = { kind = "multiline",
    get = function(c) return table.concat(c.otherProficiencies or {}, "\n") end,
    set = function(c, v)
      local out = {}
      for line in tostring(v or ""):gmatch("([^\n]+)") do
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed ~= "" then table.insert(out, trimmed) end
      end
      c.otherProficiencies = out
    end },

  field_traits = { kind = "multiline",
    get = function(c) return sub(c, "personality", {}).traits or "" end,
    set = function(c, v) sub(c, "personality", {}).traits = v end },
  field_ideals = { kind = "multiline",
    get = function(c) return sub(c, "personality", {}).ideals or "" end,
    set = function(c, v) sub(c, "personality", {}).ideals = v end },
  field_bonds = { kind = "multiline",
    get = function(c) return sub(c, "personality", {}).bonds or "" end,
    set = function(c, v) sub(c, "personality", {}).bonds = v end },
  field_flaws = { kind = "multiline",
    get = function(c) return sub(c, "personality", {}).flaws or "" end,
    set = function(c, v) sub(c, "personality", {}).flaws = v end },
}

for _, key in ipairs({ "STR", "DEX", "CON", "INT", "WIS", "CHA" }) do
  SCALARS["field_ability_" .. key] = {
    kind = "integer",
    get = function(c) return sub(c, "abilityScores", {})[key] or 10 end,
    set = function(c, v)
      local scores = sub(c, "abilityScores", {})
      scores[key] = clampInteger(v, scores[key] or 10, 1)
    end,
  }
end

-- Индексированные семейства: field_equip_<slot>, field_attack_<i>_<part>,
-- field_item_<i>_<part>, field_feat_<i>_<part>. Разбираются шаблоном, чтобы
-- реестр не приходилось расширять под каждую строку списка.
local INDEXED = {
  {
    pattern = "^field_equip_([%w_]+)$",
    kind = function() return "text" end,
    -- Подпись у всех семейств одна: (character, capture1, capture2, value).
    -- У слотов экипировки второй захват не нужен, но параметр обязателен —
    -- иначе value уезжает в _unused (уже наступали).
    get = function(c, slot, _unused)
      for _, item in ipairs(c.equipment or {}) do
        if item.slot == slot then return item.name or "" end
      end
      return ""
    end,
    set = function(c, slot, _unused, v)
      if type(c.equipment) ~= "table" then c.equipment = {} end
      for _, item in ipairs(c.equipment) do
        if item.slot == slot then item.name = v return end
      end
      table.insert(c.equipment, { slot = slot, itemId = "", name = v })
    end,
  },
  {
    pattern = "^field_attack_(%d+)_(%w+)$",
    kind = function() return "text" end,
    get = function(c, index, part)
      local attack = (c.attacks or {})[tonumber(index)] or {}
      if part == "name" then return attack.name or "" end
      if part == "bonus" then return attack.atkBonus or "" end
      return attack.damage or ""
    end,
    set = function(c, index, part, v)
      local attack = listEntry(c, "attacks", tonumber(index), ATTACK_TEMPLATE)
      if part == "name" then attack.name = v
      elseif part == "bonus" then attack.atkBonus = v
      else attack.damage = v end
    end,
  },
  {
    pattern = "^field_item_(%d+)_(%w+)$",
    kind = function(_, part) return part == "qty" and "integer" or "text" end,
    get = function(c, index, part)
      local item = (c.inventory or {})[tonumber(index)] or {}
      if part == "qty" then return item.qty or 1 end
      return item.name or ""
    end,
    set = function(c, index, part, v)
      local item = listEntry(c, "inventory", tonumber(index), ITEM_TEMPLATE)
      if part == "qty" then item.qty = clampInteger(v, item.qty or 1, 0)
      else item.name = v end
    end,
  },
  {
    pattern = "^field_custom_(%d+)_(%w+)$",
    kind = function(_, part) return part == "desc" and "multiline" or "text" end,
    get = function(c, index, part)
      local entry = (c.customGroups or {})[tonumber(index)] or {}
      if part == "title" then return entry.title or "" end
      return entry.description or ""
    end,
    set = function(c, index, part, v)
      local entry = listEntry(c, "customGroups", tonumber(index), CUSTOM_GROUP_TEMPLATE)
      if part == "title" then
        entry.title = v
      else
        entry.description = v
      end
    end,
  },
  {
    pattern = "^field_feat_(%d+)_(%w+)$",
    kind = function() return "text" end,
    get = function(c, index, part)
      local feat = (c.abilities or {})[tonumber(index)] or {}
      if part == "type" then return feat.actionType or "action" end
      if part == "desc" then return feat.description or "" end
      return feat.name or ""
    end,
    set = function(c, index, part, v)
      local feat = listEntry(c, "abilities", tonumber(index), ABILITY_TEMPLATE)
      if part == "type" then feat.actionType = v
      elseif part == "desc" then feat.description = v
      else feat.name = v end
    end,
  },
}

local function resolve(fieldId)
  local scalar = SCALARS[fieldId]
  if scalar ~= nil then
    return scalar
  end
  for _, family in ipairs(INDEXED) do
    local a, b = tostring(fieldId or ""):match(family.pattern)
    if a ~= nil then
      return {
        kind = family.kind(a, b),
        get = function(c) return family.get(c, a, b) end,
        set = function(c, v) family.set(c, a, b, v) end,
      }
    end
  end
  return nil
end

function CharacterFields.exists(fieldId)
  return resolve(fieldId) ~= nil
end

function CharacterFields.kind(fieldId)
  local field = resolve(fieldId)
  return field and field.kind or "text"
end

function CharacterFields.get(character, fieldId)
  local field = resolve(fieldId)
  if field == nil then
    return ""
  end
  local value = field.get(character)
  if value == nil then
    return ""
  end
  if type(value) == "string" then
    return decodeXmlEntities(value)
  end
  return value
end

-- Возвращает true, если поле известно и значение записано, — вызывающий по
-- этому решает, надо ли сохранять персонажа.
function CharacterFields.set(character, fieldId, value)
  local field = resolve(fieldId)
  if field == nil then
    return false
  end
  field.set(character, value)
  return true
end

return CharacterFields
