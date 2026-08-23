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
