local __tts_modules, __tts_cache = {}, {}
local function require(name)
  if __tts_cache[name] ~= nil then return __tts_cache[name] end
  local fn = __tts_modules[name]
  if fn == nil then error('module not found: ' .. tostring(name)) end
  local result = fn()
  __tts_cache[name] = result
  return result
end
__tts_modules["ui.UIController"] = function()
-- Владеет состоянием HUD'а и пере-рендерит весь UI.setXmlTable целиком при
-- любом изменении (render = f(state), без ручной мутации отдельных узлов).
--
-- Выбор персонажа (портрет -> подсветка + хотбар) и открытие полной панели
-- (вкладки со статами/шмотом/абилками) — два независимых действия с двумя
-- независимыми полями state, намеренно не связанные напрямую.
local Builders = require("ui.Builders")

local UIController = {}

local state = {
  party = {},
  partyById = {},
  selectedCharacterId = nil,
  openCharacterId = nil,
  activeTab = "stats",
}

local function render()
  local root = { Builders.partyBar(state.party, state.selectedCharacterId) }
  local ownerColor = UIController.lastPlayerColor or "White"

  if state.selectedCharacterId ~= nil then
    local selected = state.partyById[state.selectedCharacterId]
    if selected ~= nil then
      table.insert(root, Builders.hotbar(selected, ownerColor))
    end
  end

  if state.openCharacterId ~= nil then
    local opened = state.partyById[state.openCharacterId]
    if opened ~= nil then
      table.insert(root, Builders.characterPanel(opened, ownerColor, state.activeTab))
    end
  end

  UI.setXmlTable(root)
end

function UIController.setParty(party)
  state.party = party
  state.partyById = {}
  for _, character in ipairs(party) do
    state.partyById[character.id] = character
  end
  render()
end

-- Клик по портрету: только выбор (подсветка + хотбар), панель не трогает.
function UIController.selectCharacter(playerColor, characterId)
  UIController.lastPlayerColor = playerColor
  state.selectedCharacterId = characterId
  render()
end

-- Открыть полную панель для сейчас выбранного персонажа.
function UIController.openPanelForSelected(playerColor)
  UIController.lastPlayerColor = playerColor
  if state.selectedCharacterId == nil then return end
  state.openCharacterId = state.selectedCharacterId
  state.activeTab = "stats"
  render()
end

function UIController.closePanel()
  state.openCharacterId = nil
  render()
end

function UIController.setActiveTab(tabId)
  state.activeTab = tabId
  render()
end

-- Глобальные колбэки для onClick из XML — должны жить в глобальном
-- окружении объекта, поэтому объявлены без `local`.
function HUD_onPortraitClick(player, _value, id)
  local characterId = id:gsub("^portrait_", "")
  UIController.selectCharacter(player.color, characterId)
end

function CharacterSheet_onOpenClick(player, _value, _id)
  UIController.openPanelForSelected(player.color)
end

function CharacterPanel_onClose(_player, _value, _id)
  UIController.closePanel()
end

function CharacterPanel_onTabClick(_player, _value, id)
  local tabId = id:gsub("^tab_", "")
  UIController.setActiveTab(tabId)
end

-- Реальной системы эффектов способностей пока нет — это заглушка, чтобы
-- проверить, что хотбар кликабелен и знает, какого персонажа обслуживает.
function Hotbar_onAbilityClick(player, _value, id)
  local abilityId = id:gsub("^hotbar_", "")
  local character = state.partyById[state.selectedCharacterId]
  if character == nil then return end
  printToAll(string.format("%s использует способность: %s", character.name, abilityId), { 0.8, 0.8, 0.4 })
end

return UIController

end
__tts_modules["ui.Builders"] = function()
-- Чистые функции: state -> xmlTable (формат UI.setXmlTable). Никаких side
-- effect'ов и обращений к UI/Global здесь быть не должно — это упрощает
-- дальнейшее расширение (новые панели, новые билдеры).
local Builders = {}

local SLOT_LABELS = {
  mainHand = "Оружие",
  offHand = "Левая рука",
  armor = "Доспех",
  head = "Голова",
  boots = "Обувь",
  accessory = "Аксессуар",
}

local TABS = {
  { id = "stats", label = "Статы" },
  { id = "equipment", label = "Снаряжение" },
  { id = "inventory", label = "Инвентарь" },
  { id = "abilities", label = "Способности" },
}

--- HUD-полоска портретов ---------------------------------------------------

local function portraitButton(character, isSelected)
  return {
    tag = "Button",
    attributes = {
      id = "portrait_" .. character.id,
      onClick = "HUD_onPortraitClick",
      width = "64",
      height = "64",
      color = isSelected and "#c9a24b" or "#3a3a3a",
      textColor = "#ffffff",
      fontSize = "20",
    },
    value = (character.name or "?"):sub(1, 1),
  }
end

-- Полоска портретов партии слева по центру экрана. Не привязана ни к
-- одному объекту на столе — это чистый Global UI (HUD). Клик по портрету —
-- это ВЫБОР персонажа (подсветка + хотбар), а не открытие полной панели.
function Builders.partyBar(party, selectedCharacterId)
  local children = {}
  for _, character in ipairs(party) do
    table.insert(children, portraitButton(character, character.id == selectedCharacterId))
  end

  return {
    tag = "Panel",
    attributes = {
      id = "hud_party_bar",
      rectAlignment = "MiddleLeft",
      offsetXY = "12 0",
      width = "80",
      height = tostring(#party * 72 + 16),
      color = "rgba(0,0,0,0.35)",
      padding = "8 8 8 8",
    },
    children = {
      {
        tag = "VerticalLayout",
        attributes = { spacing = "8" },
        children = children,
      },
    },
  }
end

--- Панель персонажа: шапка + вкладки ---------------------------------------

local function tabHeaderButton(tab, activeTab)
  return {
    tag = "Button",
    attributes = {
      id = "tab_" .. tab.id,
      onClick = "CharacterPanel_onTabClick",
      width = "90",
      height = "32",
      color = (tab.id == activeTab) and "#c9a24b" or "#2a2420",
      textColor = (tab.id == activeTab) and "#1a1610" or "#cbb98a",
      fontSize = "13",
    },
    value = tab.label,
  }
end

local function tabHeader(activeTab)
  local children = {}
  for _, tab in ipairs(TABS) do
    table.insert(children, tabHeaderButton(tab, activeTab))
  end
  return {
    tag = "HorizontalLayout",
    attributes = { spacing = "4" },
    children = children,
  }
end

local function statRow(label, value)
  return {
    tag = "HorizontalLayout",
    children = {
      { tag = "Text", attributes = { width = "90", fontSize = "16" }, value = label },
      { tag = "Text", attributes = { width = "60", fontSize = "16" }, value = tostring(value) },
    },
  }
end

local function sectionTitle(text)
  return { tag = "Text", attributes = { fontSize = "18", color = "#c9a24b" }, value = text }
end

local function emptyRow(text)
  return { tag = "Text", attributes = { fontSize = "14", color = "#8a8070" }, value = text or "—" }
end

local function statsTabContent(character)
  return {
    tag = "VerticalLayout",
    attributes = { spacing = "6" },
    children = {
      statRow("HP", string.format("%d / %d", character.hp.current, character.hp.max)),
      statRow("STR", character.abilityScores.STR),
      statRow("DEX", character.abilityScores.DEX),
      statRow("CON", character.abilityScores.CON),
      statRow("INT", character.abilityScores.INT),
      statRow("WIS", character.abilityScores.WIS),
      statRow("CHA", character.abilityScores.CHA),
    },
  }
end

local function equipmentTabContent(character)
  local rows = {}
  for _, slot in ipairs(character.equipment or {}) do
    local label = SLOT_LABELS[slot.slot] or slot.slot
    table.insert(rows, statRow(label, slot.name or "пусто"))
  end
  if #rows == 0 then
    table.insert(rows, emptyRow())
  end
  return { tag = "VerticalLayout", attributes = { spacing = "6" }, children = rows }
end

local function inventoryTabContent(character)
  local rows = {}
  for _, entry in ipairs(character.inventory or {}) do
    table.insert(rows, statRow(entry.name or entry.itemId, "x" .. tostring(entry.qty)))
  end
  if #rows == 0 then
    table.insert(rows, emptyRow("Инвентарь пуст"))
  end
  return { tag = "VerticalLayout", attributes = { spacing = "6" }, children = rows }
end

local function abilitiesTabContent(character)
  local rows = {}
  for _, ability in ipairs(character.abilities or {}) do
    table.insert(rows, { tag = "Text", attributes = { fontSize = "14" }, value = ability.name or ability.id })
  end
  if #rows == 0 then
    table.insert(rows, emptyRow("Способностей нет"))
  end
  return { tag = "VerticalLayout", attributes = { spacing = "6" }, children = rows }
end

local TAB_CONTENT_BUILDERS = {
  stats = statsTabContent,
  equipment = equipmentTabContent,
  inventory = inventoryTabContent,
  abilities = abilitiesTabContent,
}

-- Полноценная игровая панель персонажа (не чарник создания): вкладки
-- Статы/Снаряжение/Инвентарь/Способности. Джойн inventory/equipment/abilities
-- с templates/items и templates/abilities — следующий шаг (TODO), пока имена
-- продублированы прямо в данных персонажа.
function Builders.characterPanel(character, ownerColor, activeTab)
  activeTab = activeTab or "stats"
  local contentBuilder = TAB_CONTENT_BUILDERS[activeTab] or statsTabContent

  return {
    tag = "Panel",
    attributes = {
      id = "character_panel",
      rectAlignment = "MiddleLeft",
      offsetXY = "110 0",
      width = "340",
      height = "440",
      color = "rgba(20,16,10,0.92)",
      padding = "16 16 16 16",
      visibility = ownerColor,
    },
    children = {
      {
        tag = "VerticalLayout",
        attributes = { spacing = "10" },
        children = {
          {
            tag = "Text",
            attributes = { fontSize = "24", color = "#e8d9b0" },
            value = string.format("%s — %s %s (ур. %d)", character.name, character.race, character.class, character.level),
          },
          tabHeader(activeTab),
          contentBuilder(character),
          {
            tag = "Button",
            attributes = { id = "character_panel_close", onClick = "CharacterPanel_onClose", width = "100", height = "32" },
            value = "Закрыть",
          },
        },
      },
    },
  }
end

--- Нижний хотбар (в духе Baldur's Gate) -------------------------------------

local function hotbarSlotButton(character, abilityId)
  local ability = nil
  for _, a in ipairs(character.abilities or {}) do
    if a.id == abilityId then
      ability = a
      break
    end
  end
  local label = ability and ability.name or abilityId
  return {
    tag = "Button",
    attributes = {
      id = "hotbar_" .. abilityId,
      onClick = "Hotbar_onAbilityClick",
      width = "72",
      height = "48",
      color = "#2a2420",
      textColor = "#e8d9b0",
      fontSize = "12",
    },
    value = label,
  }
end

local function openSheetButton()
  return {
    tag = "Button",
    attributes = {
      id = "hotbar_open_sheet",
      onClick = "CharacterSheet_onOpenClick",
      width = "56",
      height = "48",
      color = "#4a3a1a",
      textColor = "#e8d9b0",
      fontSize = "11",
    },
    value = "Чарник",
  }
end

-- Полоска активных способностей ВЫБРАННОГО персонажа внизу экрана — виден
-- при выборе портрета, не зависит от того, открыта ли полная панель.
-- Состав слотов берётся из character.hotbar (данные, не хардкод конкретных
-- способностей). Первая кнопка — открыть полную панель для того же персонажа,
-- это отдельное действие от самого выбора.
function Builders.hotbar(character, ownerColor)
  local children = { openSheetButton() }
  for _, abilityId in ipairs(character.hotbar or {}) do
    table.insert(children, hotbarSlotButton(character, abilityId))
  end

  return {
    tag = "Panel",
    attributes = {
      id = "hud_hotbar",
      rectAlignment = "LowerCenter",
      offsetXY = "0 12",
      width = tostring(#children * 80 + 16),
      height = "64",
      color = "rgba(0,0,0,0.35)",
      padding = "8 8 8 8",
      visibility = ownerColor,
    },
    children = {
      {
        tag = "HorizontalLayout",
        attributes = { spacing = "8" },
        children = children,
      },
    },
  }
end

return Builders

end
__tts_modules["data.DataLoader"] = function()
-- Единственное место, которое знает, откуда берутся данные.
-- Остальной код всегда зовёт DataLoader.loadParty(callback) и получает массив
-- персонажей — не важно, пришёл он по сети или из MockData (сгенерирован из
-- data/characters/*.json, см. tools/tts_bridge.py sync-mock).
local MockData = require("data.MockData")

local DataLoader = {}

-- TODO: когда JSON захостен (например GitHub raw), выставить USE_MOCK = false
-- и указать реальный PARTY_URL.
local USE_MOCK = true
local PARTY_URL = "https://example.com/kvs-data/characters.json"

function DataLoader.loadParty(callback)
  if USE_MOCK then
    callback(MockData)
    return
  end

  WebRequest.get(PARTY_URL, function(request)
    if request.is_error then
      printToAll("[DataLoader] Ошибка загрузки party: " .. request.error, { 1, 0.3, 0.3 })
      callback({})
      return
    end

    local ok, decoded = pcall(JSON.decode, request.text)
    if not ok or decoded == nil then
      printToAll("[DataLoader] Не удалось разобрать JSON партии", { 1, 0.3, 0.3 })
      callback({})
      return
    end

    callback(decoded)
  end)
end

return DataLoader

end
__tts_modules["data.MockData"] = function()
-- AUTO-GENERATED by `python3 tools/tts_bridge.py sync-mock`.
-- Не редактировать руками — правьте data/characters/*.json и запустите
-- sync-mock заново (или push, он делает это сам). Ниже — не Lua-копия,
-- а сырой JSON из тех файлов, склеенный в массив 1:1.
return JSON.decode([==[
[
{
  "id": "char_kellen",
  "name": "Кэллен",
  "portrait": "",
  "race": "Human",
  "class": "Fighter",
  "level": 3,
  "hp": { "current": 24, "max": 28 },
  "abilityScores": {
    "STR": 16,
    "DEX": 12,
    "CON": 14,
    "INT": 10,
    "WIS": 11,
    "CHA": 13
  },
  "equipment": [
    { "slot": "mainHand", "itemId": "longsword", "name": "Длинный меч" },
    { "slot": "offHand", "itemId": "shield", "name": "Щит" },
    { "slot": "armor", "itemId": "leather_armor", "name": "Кожаный доспех" },
    { "slot": "head", "itemId": null, "name": null },
    { "slot": "boots", "itemId": null, "name": null },
    { "slot": "accessory", "itemId": null, "name": null }
  ],
  "inventory": [
    { "itemId": "potion_healing", "name": "Зелье лечения", "qty": 2 },
    { "itemId": "torch", "name": "Факел", "qty": 3 }
  ],
  "abilities": [
    { "id": "power_attack", "name": "Мощный удар" },
    { "id": "second_wind", "name": "Второе дыхание" }
  ],
  "hotbar": ["power_attack", "second_wind"],
  "notes": ""
},
{
  "id": "char_mira",
  "name": "Мира",
  "portrait": "",
  "race": "Elf",
  "class": "Wizard",
  "level": 3,
  "hp": { "current": 16, "max": 18 },
  "abilityScores": {
    "STR": 8,
    "DEX": 14,
    "CON": 12,
    "INT": 17,
    "WIS": 13,
    "CHA": 10
  },
  "equipment": [
    { "slot": "mainHand", "itemId": "quarterstaff", "name": "Посох" },
    { "slot": "offHand", "itemId": null, "name": null },
    { "slot": "armor", "itemId": null, "name": null },
    { "slot": "head", "itemId": null, "name": null },
    { "slot": "boots", "itemId": null, "name": null },
    { "slot": "accessory", "itemId": "amulet_arcana", "name": "Амулет тайной силы" }
  ],
  "inventory": [
    { "itemId": "potion_healing", "name": "Зелье лечения", "qty": 1 }
  ],
  "abilities": [
    { "id": "firebolt", "name": "Огненный снаряд" },
    { "id": "shield_spell", "name": "Щит (заклинание)" }
  ],
  "hotbar": ["firebolt", "shield_spell"],
  "notes": ""
}
]
]==])

end

local DataLoader = require("data.DataLoader")
local UIController = require("ui.UIController")

function onLoad()
  DataLoader.loadParty(function(party)
    UIController.setParty(party)
  end)
end

function onUpdate()
end