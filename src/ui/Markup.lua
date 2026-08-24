-- Кастомные теги в разметке: <Section title="..."><Tile .../></Section>.
-- Разметка становится картинкой вёрстки, а весь бойлерплейт TTS XML
-- (childForceExpandWidth, обёртки Panel вокруг layout-групп) живёт в одном
-- месте — в layout/ соответствующего компонента.
--
-- Как это работает: атрибуты тега становятся props компонента, вложенное
-- содержимое — props.content. Компонент рендерит свою разметку, в которой
-- тоже могут быть кастомные теги (раскрываются рекурсивно).
local Markup = {}

-- Tег -> модуль. require ленивый и намеренно: компоненты сами зовут
-- Component.render, который зовёт этот модуль, — при загрузке был бы цикл.
-- Значение — функция с литеральным require, а не строка с путём: бандлеры
-- (и luabundle расширения, и tools/tts_bridge.py) видят только вызовы
-- require со строковым литералом. Динамический вызов по строке из таблицы
-- собрался бы без этих модулей, и в игре тег падал бы на module not found.
-- Ленивость при этом сохраняется: цикла загрузки нет.
-- Примитивов раскладки (<Row>, <Col>, <Box>, <Scroll>, <Anchor>) здесь нет
-- намеренно: их разбирает ui/Layout.lua уже по готовому дереву, когда у него
-- на руках все дети и можно посчитать размеры. Компонент так не может —
-- содержимое раскрывается ДО родителя, поэтому раньше каждый размер и
-- приходилось писать руками на каждом уровне.
local REGISTRY = {
  -- структурные
  Section = function() return require("ui.components.Section") end,
  Caption = function() return require("ui.components.Caption") end,
  Note = function() return require("ui.components.Note") end,
  Tile = function() return require("ui.components.Tile") end,
  Slot = function() return require("ui.components.Slot") end,
  StatBar = function() return require("ui.components.StatBar") end,
  Frame = function() return require("ui.components.Frame") end,
  Badge = function() return require("ui.components.Badge") end,

  -- HUD
  PartyRail = function() return require("ui.components.PartyRail") end,
  PortraitButton = function() return require("ui.components.PortraitButton") end,
  AddCharacterButton = function() return require("ui.components.AddCharacterButton") end,
  CharacterSheet = function() return require("ui.components.CharacterSheet") end,

  -- режимные обёртки: показать содержимое только в просмотре / только в визарде
  ViewOnly = function() return require("ui.sheet.ViewOnly") end,
  WizardOnly = function() return require("ui.sheet.WizardOnly") end,

  -- привязанные к данным: берут персонажа и режим из контекста рендера
  Field = function() return require("ui.sheet.Field") end,
  LabeledField = function() return require("ui.sheet.LabeledField") end,
  HeaderChip = function() return require("ui.sheet.HeaderChip") end,
  SignedValue = function() return require("ui.sheet.SignedValue") end,
  PortraitLetter = function() return require("ui.sheet.PortraitLetter") end,
  ClassLine = function() return require("ui.sheet.ClassLine") end,
  Experience = function() return require("ui.sheet.Experience") end,
  AbilityTile = function() return require("ui.sheet.AbilityTile") end,
  SaveRow = function() return require("ui.sheet.SaveRow") end,
  SkillList = function() return require("ui.sheet.SkillList") end,
  EquipSlot = function() return require("ui.sheet.EquipSlot") end,
  Resource = function() return require("ui.sheet.Resource") end,
  CombatTile = function() return require("ui.sheet.CombatTile") end,
  CombatSummary = function() return require("ui.sheet.CombatSummary") end,
  Attacks = function() return require("ui.sheet.Attacks") end,
  Features = function() return require("ui.sheet.Features") end,
  InventoryList = function() return require("ui.sheet.InventoryList") end,
  CustomGroups = function() return require("ui.sheet.CustomGroups") end,
  SheetButton = function() return require("ui.sheet.SheetButton") end,
}

-- Контекст рендера: персонаж и режим листа. Нужен, чтобы тег в разметке мог
-- сам достать значение (<Field name="field_name"/>) — иначе разметка снова
-- превратится в набор {{СЛОTОВ}}, которые заполняет Lua.
local contextStack = {}

-- Цвет в разметке можно назвать ролью Theme (color="sheetBg") даже на сырых
-- тегах TTS: разрешаем роли одним проходом по готовому XML. Литералы (#hex,
-- rgba(...)) под шаблон не подходят и проходят мимо.
--
-- Ищем любой атрибут, в имени которого есть "color": кроме color это ещё
-- colors (четыре состояния кнопки), textColor, caretColor, iconColor. Роль
-- может разворачиваться в строку с "|" — так заданы состояния кнопок.
local function resolveColorRoles(xml)
  local Theme = require("ui.Theme")
  return (xml:gsub('([%a][%w]*)="(%a[%w]*)"', function(attribute, name)
    if attribute:lower():find("color", 1, true) == nil then
      return attribute .. '="' .. name .. '"'
    end
    local resolved = Theme[name]
    if type(resolved) ~= "string" then
      return attribute .. '="' .. name .. '"'
    end
    return attribute .. '="' .. resolved .. '"'
  end))
end

-- Раскрытие кастомных тегов БЕЗ раскладки: результат — дерево из примитивов
-- (<Row>/<Col>/<Box>/<Scroll>/<Anchor>) с объявленными размерами. Отдельно от
-- render, чтобы тесты (tools/layout_check.lua) могли посмотреть на дерево до
-- того, как оно превратилось в плоский XML.
function Markup.compose(template, context)
  table.insert(contextStack, context)
  local ok, result = pcall(Markup.expand, template)
  table.remove(contextStack)
  if not ok then
    error(result, 0)
  end

  -- Страховка от самого коварного отказа: если разметка не раскрылась (устарел
  -- Templates.lua, опечатка в имени тега), TTS молча проигнорирует незнакомые
  -- элементы и покажет пустую панель. Лучше громкая ошибка в консоли.
  local leftover = result:match("{{[%w_]+}}")
  if leftover ~= nil then
    error("Markup: в готовом XML осталась подстановка " .. leftover, 0)
  end
  for name in pairs(REGISTRY) do
    if result:find("<" .. name, 1, true) ~= nil then
      error("Markup: тег <" .. name .. "> не раскрылся (пересоберите Templates.lua)", 0)
    end
  end

  return result
end

function Markup.render(template, context)
  -- Tри шага, каждый со своей задачей: раскрыть теги -> посчитать размеры ->
  -- разрешить роли цветов. Раскладка идёт по дереву целиком, поэтому размер
  -- ребёнка может зависеть от размера родителя — из-за отсутствия этого шага
  -- каждое число раньше и жило в разметке руками.
  local composed = Markup.compose(template, context)
  local solved = require("ui.Layout").solve(composed)
  return resolveColorRoles(solved)
end

function Markup.context()
  local context = contextStack[#contextStack]
  if context == nil then
    error("Markup: компонент требует контекст рендера (Markup.render)", 0)
  end
  return context
end

function Markup.isComponent(name)
  return REGISTRY[name] ~= nil
end

-- Ищет ">" закрывающий открывающий тег, не спотыкаясь о ">" внутри кавычек.
local function findTagEnd(source, from)
  local i = from
  while i <= #source do
    local c = source:sub(i, i)
    if c == '"' then
      local close = source:find('"', i + 1, true)
      if close == nil then
        return nil
      end
      i = close + 1
    elseif c == ">" then
      return i
    else
      i = i + 1
    end
  end
  return nil
end

local function isTagStart(source, position, name)
  local nextChar = source:sub(position + #name + 1, position + #name + 1)
  return nextChar == "" or nextChar == ">" or nextChar == "/" or nextChar:match("%s") ~= nil
end

-- Закрывающий тег с учётом вложенности одноимённых (Box внутри Box).
local function findMatchingClose(source, name, from)
  local depth, pos = 1, from
  local openTag, closeTag = "<" .. name, "</" .. name .. ">"

  while true do
    local closeStart, closeEnd = source:find(closeTag, pos, true)
    if closeStart == nil then
      error("Markup: не найден закрывающий " .. closeTag, 0)
    end

    local openStart = pos
    local nestedStart = nil
    while true do
      local candidate = source:find(openTag, openStart, true)
      if candidate == nil or candidate > closeStart then
        break
      end
      if isTagStart(source, candidate, name) then
        nestedStart = candidate
        break
      end
      openStart = candidate + 1
    end

    if nestedStart ~= nil then
      local tagEnd = findTagEnd(source, nestedStart)
      if tagEnd == nil then
        error("Markup: незакрытый тег " .. openTag, 0)
      end
      -- Самозакрывающийся вложенный тег глубину не увеличивает.
      if source:sub(tagEnd - 1, tagEnd) ~= "/>" then
        depth = depth + 1
      end
      pos = tagEnd + 1
    else
      depth = depth - 1
      if depth == 0 then
        return closeStart, closeEnd
      end
      pos = closeEnd + 1
    end
  end
end

local function parseAttributes(chunk)
  local props = {}
  -- Имена атрибутов в наших тегах/разметке ASCII (slot, label, onClick, ...).
  -- Явно ограничиваем парсер ASCII-ключами, чтобы locale-зависимый `%w`
  -- не подхватывал случайные кириллические байты как отдельные имена props.
  for name, value in chunk:gmatch('([A-Za-z_][A-Za-z0-9_]*)%s*=%s*"([^"]*)"') do
    -- Числа приводим к числам: компоненты считают на них арифметику
    -- (StatBar.ratio), а из XML всё приходит строками. Но только если запись
    -- числа не теряется: tonumber("+2") = 2, и модификатор характеристики
    -- уезжал в разметку без плюса (наступали — «+2» превращалось в «2»).
    local number = tonumber(value)
    if number ~= nil and tostring(number) == value then
      props[name] = number
    else
      props[name] = value
    end
  end
  return props
end

function Markup.expand(source)
  local out, pos = {}, 1

  while true do
    local start = source:find("<", pos, true)
    if start == nil then
      table.insert(out, source:sub(pos))
      break
    end

    local name = source:match("^<([%a][%w_]*)", start)
    if name == nil or not Markup.isComponent(name) or not isTagStart(source, start, name) then
      table.insert(out, source:sub(pos, start))
      pos = start + 1
    else
      local tagEnd = findTagEnd(source, start)
      if tagEnd == nil then
        error("Markup: незакрытый тег <" .. name, 0)
      end

      table.insert(out, source:sub(pos, start - 1))
      local attributes = source:sub(start + #name + 1, tagEnd - 1)
      local selfClosing = attributes:match("/%s*$") ~= nil
      local props = parseAttributes(attributes)
      local after

      if selfClosing then
        props.content = ""
        after = tagEnd + 1
      else
        local closeStart, closeEnd = findMatchingClose(source, name, tagEnd + 1)
        props.content = Markup.expand(source:sub(tagEnd + 1, closeStart - 1))
        after = closeEnd + 1
      end

      local component = REGISTRY[name]()

      -- content отдаём только тем компонентам, которые его объявили: у Tile
      -- содержимое приходит в value, и безусловный content ронял бы <Tile/>
      -- на проверке неизвестных props.
      if component.defaults ~= nil and component.defaults.content == nil then
        if props.content ~= "" then
          error("Markup: <" .. name .. "> не принимает вложенное содержимое", 0)
        end
        props.content = nil
      end

      table.insert(out, component.render(props))
      pos = after
    end
  end

  return table.concat(out)
end

return Markup
