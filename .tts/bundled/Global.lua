local __tts_modules, __tts_cache = {}, {}
local function require(name)
  if __tts_cache[name] ~= nil then return __tts_cache[name] end
  local fn = __tts_modules[name]
  if fn == nil then error('module not found: ' .. tostring(name)) end
  local result = fn()
  __tts_cache[name] = result
  return result
end
__tts_modules["Global"] = function()
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
  return math.floor(n)
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
end
__tts_modules["ui.builders.UIBuilder"] = function()
local UIBuilder = {}

local function replaceAll(template, replacements)
  local result = template
  for key, value in pairs(replacements) do
    result = result:gsub("{{" .. key .. "}}", value or "")
  end
  return result
end

function UIBuilder.buildPortrait(character, isSelected)
  local portraitTemplate = require("ui.templates.PortraitButton")
  local borderColor = isSelected and "#e6cd85" or "#7f7752"
  local bgColor = isSelected and "rgba(0.231, 0.318, 0.176, 0.8)" or "rgba(0.141, 0.141, 0.110, 0.8)"
  local hp = character.hp or {}
  local hpText = string.format("%d/%d", hp.current or 0, hp.max or 0)

  return replaceAll(portraitTemplate, {
    CHARACTER_ID = character.id,
    BORDER_COLOR = borderColor,
    BG_COLOR = bgColor,
    INITIAL = (character.name or "?"):sub(1, 1),
    HP = hpText,
  })
end

function UIBuilder.buildPartyHUD(party, selectedCharacterId)
  local portraitsTemplate = require("ui.templates.PartyPortraits")
  local addTemplate = require("ui.templates.AddCharacterButton")
  local buttons = {}

  for _, character in ipairs(party) do
    local isSelected = character.id == selectedCharacterId
    table.insert(buttons, UIBuilder.buildPortrait(character, isSelected))
  end

  return replaceAll(portraitsTemplate, {
    PORTRAIT_BUTTONS = table.concat(buttons),
    ADD_BUTTON = addTemplate,
  })
end

function UIBuilder.buildCharacterSheet(character)
  if not character then
    return ""
  end
  local renderer = require("ui.builders.CharacterSheetRenderer")
  return renderer.render(character)
end

function UIBuilder.buildMainUI(party, selectedCharacterId, sheetVisible)
  local mainTemplate = require("ui.templates.MainUI")
  local partyHUD = UIBuilder.buildPartyHUD(party, selectedCharacterId)
  local characterSheet = ""

  if sheetVisible and selectedCharacterId then
    for _, character in ipairs(party) do
      if character.id == selectedCharacterId then
        characterSheet = UIBuilder.buildCharacterSheet(character)
        break
      end
    end
  end

  return replaceAll(mainTemplate, {
    PARTY_PORTRAITS = partyHUD,
    CHARACTER_SHEET = characterSheet,
  })
end

return UIBuilder

end
__tts_modules["ui.templates.MainUI"] = function()
return [[<Panel>
  <Panel rectAlignment="MiddleLeft" offsetX="90" width="140" height="800">
    {{PARTY_PORTRAITS}}
  </Panel>
  {{CHARACTER_SHEET}}
</Panel>
]]
end
__tts_modules["ui.builders.CharacterSheetRenderer"] = function()
local Template = require("ui.templates.CharacterSheetUI")

local CharacterSheetRenderer = {}

local function escapeXml(text)
  local s = tostring(text or "")
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  s = s:gsub("\"", "&quot;")
  s = s:gsub("'", "&apos;")
  s = s:gsub("\r\n", " ")
  s = s:gsub("\n", " ")
  return s
end

local function replaceAll(template, replacements)
  local out = template
  for key, value in pairs(replacements) do
    out = out:gsub("{{" .. key .. "}}", value)
  end
  return out
end

local function equipmentName(character, slot)
  for _, item in ipairs(character.equipment or {}) do
    if item.slot == slot then
      return item.name or ""
    end
  end
  return ""
end

local function skillsCsv(character)
  return table.concat(character.proficientSkills or {}, ", ")
end

function CharacterSheetRenderer.render(character)
  local ability = character.abilityScores or {}
  local hp = character.hp or {}
  local firstWeapon = (character.attacks or {})[1] or {}
  local firstAbility = (character.abilities or {})[1] or {}

  return replaceAll(Template, {
    CHARACTER_ID = escapeXml(character.id or ""),
    NAME = escapeXml(character.name or ""),
    RACE = escapeXml(character.race or ""),
    CLASS = escapeXml(character.class or ""),
    LEVEL = escapeXml(tostring(character.level or 1)),
    PLAYER_NAME = escapeXml(character.playerName or ""),
    HP_CURRENT = escapeXml(tostring(hp.current or 0)),
    HP_MAX = escapeXml(tostring(hp.max or 0)),
    SPEED = escapeXml(tostring(character.speed or 0)),
    STR = escapeXml(tostring(ability.STR or 10)),
    DEX = escapeXml(tostring(ability.DEX or 10)),
    CON = escapeXml(tostring(ability.CON or 10)),
    INT = escapeXml(tostring(ability.INT or 10)),
    WIS = escapeXml(tostring(ability.WIS or 10)),
    CHA = escapeXml(tostring(ability.CHA or 10)),
    BACKGROUND = escapeXml(character.background or ""),
    ALIGNMENT = escapeXml(character.alignment or ""),
    SKILLS_CSV = escapeXml(skillsCsv(character)),
    EQUIP_MAIL = escapeXml(equipmentName(character, "mail")),
    EQUIP_HELM = escapeXml(equipmentName(character, "helm")),
    EQUIP_GLOVE = escapeXml(equipmentName(character, "glove")),
    EQUIP_BOOT = escapeXml(equipmentName(character, "boot")),
    WEAPON_NAME = escapeXml(firstWeapon.name or ""),
    WEAPON_BONUS = escapeXml(firstWeapon.atkBonus or ""),
    WEAPON_DAMAGE = escapeXml(firstWeapon.damage or ""),
    ABILITY_NAME = escapeXml(firstAbility.name or ""),
    ABILITY_TYPE = escapeXml(firstAbility.actionType or "action"),
  })
end

return CharacterSheetRenderer

end
__tts_modules["ui.templates.CharacterSheetUI"] = function()
return [[<Panel id="character_sheet_root" rectAlignment="MiddleCenter" width="1320" height="900" color="rgba(0.078,0.063,0.039,0.96)">
  <VerticalLayout padding="16 16 16 16" spacing="10">
    <Panel width="1288" height="64" color="#141710">
      <HorizontalLayout padding="10 10 10 10" spacing="10">
        <Text fontSize="22" color="#e6cd85">Редактор персонажа</Text>
        <Text fontSize="14" color="#a1966f">ID: {{CHARACTER_ID}}</Text>
        <Button width="120" height="36" fontSize="14" color="#7f7752" onClick="closeSheet">Закрыть</Button>
        <Button width="120" height="36" fontSize="14" color="#8e3b34" onClick="deleteCharacter">Удалить</Button>
      </HorizontalLayout>
    </Panel>

    <HorizontalLayout spacing="10">
      <VerticalLayout width="420" spacing="8">
        <Panel width="420" height="306" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">ОСНОВНОЕ</Text>
            <Text fontSize="10" color="#a1966f">Имя</Text>
            <InputField id="field_name" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{NAME}}</InputField>
            <Text fontSize="10" color="#a1966f">Раса</Text>
            <InputField id="field_race" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{RACE}}</InputField>
            <Text fontSize="10" color="#a1966f">Класс</Text>
            <InputField id="field_class" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{CLASS}}</InputField>
            <Text fontSize="10" color="#a1966f">Уровень</Text>
            <InputField id="field_level" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{LEVEL}}</InputField>
            <Text fontSize="10" color="#a1966f">Игрок</Text>
            <InputField id="field_player_name" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{PLAYER_NAME}}</InputField>
          </VerticalLayout>
        </Panel>

        <Panel width="420" height="220" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">РЕСУРСЫ</Text>
            <Text fontSize="10" color="#a1966f">HP текущие</Text>
            <InputField id="field_hp_current" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{HP_CURRENT}}</InputField>
            <Text fontSize="10" color="#a1966f">HP максимум</Text>
            <InputField id="field_hp_max" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{HP_MAX}}</InputField>
            <Text fontSize="10" color="#a1966f">Скорость</Text>
            <InputField id="field_speed" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{SPEED}}</InputField>
          </VerticalLayout>
        </Panel>
      </VerticalLayout>

      <VerticalLayout width="420" spacing="8">
        <Panel width="420" height="306" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">ХАРАКТЕРИСТИКИ</Text>
            <Text fontSize="10" color="#a1966f">STR</Text>
            <InputField id="field_ability_STR" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{STR}}</InputField>
            <Text fontSize="10" color="#a1966f">DEX</Text>
            <InputField id="field_ability_DEX" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{DEX}}</InputField>
            <Text fontSize="10" color="#a1966f">CON</Text>
            <InputField id="field_ability_CON" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{CON}}</InputField>
            <Text fontSize="10" color="#a1966f">INT</Text>
            <InputField id="field_ability_INT" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{INT}}</InputField>
            <Text fontSize="10" color="#a1966f">WIS</Text>
            <InputField id="field_ability_WIS" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{WIS}}</InputField>
            <Text fontSize="10" color="#a1966f">CHA</Text>
            <InputField id="field_ability_CHA" width="390" height="28" onEndEdit="onCharacterFieldChanged" characterValidation="Integer" interactable="true" readOnly="false" lineType="SingleLine">{{CHA}}</InputField>
          </VerticalLayout>
        </Panel>

        <Panel width="420" height="220" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">ЛОР</Text>
            <Text fontSize="10" color="#a1966f">Бэкграунд</Text>
            <InputField id="field_background" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{BACKGROUND}}</InputField>
            <Text fontSize="10" color="#a1966f">Мировоззрение</Text>
            <InputField id="field_alignment" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{ALIGNMENT}}</InputField>
          </VerticalLayout>
        </Panel>
      </VerticalLayout>

      <VerticalLayout width="420" spacing="8">
        <Panel width="420" height="160" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">НАВЫКИ (CSV)</Text>
            <Text fontSize="10" color="#a1966f">Пример: athletics, perception, stealth</Text>
            <InputField id="field_skills_csv" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{SKILLS_CSV}}</InputField>
          </VerticalLayout>
        </Panel>

        <Panel width="420" height="186" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">ЭКВИП (имена)</Text>
            <InputField id="field_equip_mail" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{EQUIP_MAIL}}</InputField>
            <InputField id="field_equip_helm" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{EQUIP_HELM}}</InputField>
            <InputField id="field_equip_glove" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{EQUIP_GLOVE}}</InputField>
            <InputField id="field_equip_boot" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{EQUIP_BOOT}}</InputField>
          </VerticalLayout>
        </Panel>

        <Panel width="420" height="164" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">ОРУЖИЕ (первое)</Text>
            <InputField id="field_weapon_name" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{WEAPON_NAME}}</InputField>
            <InputField id="field_weapon_bonus" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{WEAPON_BONUS}}</InputField>
            <InputField id="field_weapon_damage" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{WEAPON_DAMAGE}}</InputField>
          </VerticalLayout>
        </Panel>

        <Panel width="420" height="148" color="#12150e">
          <VerticalLayout padding="10 10 10 10" spacing="5">
            <Text fontSize="12" color="#a89328">АБИЛКА (первая)</Text>
            <InputField id="field_ability_name" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{ABILITY_NAME}}</InputField>
            <InputField id="field_ability_type" width="390" height="28" onEndEdit="onCharacterFieldChanged" interactable="true" readOnly="false" lineType="SingleLine">{{ABILITY_TYPE}}</InputField>
          </VerticalLayout>
        </Panel>
      </VerticalLayout>
    </HorizontalLayout>
  </VerticalLayout>
</Panel>
]]
end
__tts_modules["ui.templates.AddCharacterButton"] = function()
return [[<Panel width="120" height="120" color="#b08a2e">
  <Button id="create_character" width="114" height="114" color="rgba(0.141, 0.141, 0.110, 0.8)" onClick="createCharacter">
    <Text alignment="MiddleCenter" fontSize="44" color="#e6cd85">+</Text>
  </Button>
</Panel>
]]
end
__tts_modules["ui.templates.PartyPortraits"] = function()
return [[<Panel width="140" height="800" color="rgba(0.078,0.063,0.039,0.92)">
  <VerticalLayout
    padding="10 10 10 10"
    spacing="10"
    childAlignment="UpperCenter"
    childControlWidth="false"
    childControlHeight="false"
    childForceExpandWidth="false"
    childForceExpandHeight="false">
    {{PORTRAIT_BUTTONS}}
    {{ADD_BUTTON}}
  </VerticalLayout>
</Panel>
]]
end
__tts_modules["ui.templates.PortraitButton"] = function()
return [[<Panel width="120" height="120" color="{{BORDER_COLOR}}">
  <Button id="character_{{CHARACTER_ID}}" width="114" height="114" color="{{BG_COLOR}}" onClick="selectCharacter">
    <VerticalLayout padding="4 4 4 4" spacing="2">
      <Text alignment="UpperCenter" fontSize="40" color="#e6cd85">{{INITIAL}}</Text>
      <Text alignment="LowerCenter" fontSize="14" color="#f0dfae">{{HP}}</Text>
    </VerticalLayout>
  </Button>
</Panel>
]]
end
__tts_modules["core.PersistenceService"] = function()
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

end
__tts_modules["core.ModelValidators"] = function()
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

end
__tts_modules["core.ModelTemplates"] = function()
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

end

require("Global")