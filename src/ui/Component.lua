-- Движок компонентов: подстановка {{KEY}} в разметку + слияние props с
-- дефолтами. Ничего не знает ни про конкретные компоненты, ни про TTS —
-- чистые функции над строками.
local Component = {}

local CONFUSABLES = {
  ["а"] = "a", ["А"] = "A",
  ["е"] = "e", ["Е"] = "E",
  ["о"] = "o", ["О"] = "O",
  ["р"] = "p", ["Р"] = "P",
  ["с"] = "c", ["С"] = "C",
  ["х"] = "x", ["Х"] = "X",
  ["у"] = "y", ["У"] = "Y",
  ["к"] = "k", ["К"] = "K",
  ["м"] = "m", ["М"] = "M",
  ["т"] = "t", ["Т"] = "T",
  ["в"] = "b", ["В"] = "B",
  ["н"] = "h", ["Н"] = "H",
  ["і"] = "i", ["І"] = "I",
}

local function normalizeKey(key)
  if type(key) ~= "string" then
    return key
  end
  return (key:gsub("[%z\1-\127\194-\244][\128-\191]*", function(ch)
    return CONFUSABLES[ch] or ch
  end))
end

-- Подстановка идёт ОДНИМ проходом через функцию-замену, а не циклом gsub по
-- ключам, и это принципиально:
--   * в строке замены gsub значения `%` и `%1` имеют особый смысл — имя
--     персонажа с процентом ломало бы рендер;
--   * при последовательных gsub значение, само содержащее {{...}}, попало бы
--     под подстановку на следующей итерации (порядок ключей в pairs случаен).
function Component.render(template, values)
  -- Шаблоны лежат в одной таблице ui/generated/Templates.lua, поэтому опечатка
  -- в имени даёт nil, а не отсутствующий модуль: ловим здесь, а не в gsub.
  if type(template) ~= "string" then
    error("Component.render: шаблон не найден (проверьте имя в ui/generated/Templates.lua)", 2)
  end

  local missing = {}
  local out = template:gsub("{{([%w_]+)}}", function(key)
    local value = values[key]
    if value == nil then
      table.insert(missing, key)
      return ""
    end
    return tostring(value)
  end)

  if #missing > 0 then
    error("Component.render: нет значений для " .. table.concat(missing, ", "), 2)
  end

  -- Сначала подстановка, потом раскрытие кастомных тегов: к этому моменту в
  -- атрибутах уже конкретные значения, а вставленные из Lua фрагменты
  -- раскрыты своими компонентами.
  return require("ui.Markup").expand(out)
end

-- Слияние props с дефолтами компонента. Неизвестный ключ — это ошибка, а не
-- молча проигнорированный props: в песочнице TTS нет линтера, и опечатка
-- вроде `onclick=` иначе проявилась бы только мёртвой кнопкой.
function Component.props(defaults, props)
  local function resolveDefaultKey(key)
    if defaults[key] ~= nil then
      return key
    end
    local normalized = normalizeKey(key)
    if defaults[normalized] ~= nil then
      return normalized
    end
    -- Подстраховка под поломанный UTF-8 парс в имени атрибута: если пришла
    -- одна буква (например "а" вместо "alignment"), подбираем единственный
    -- ключ дефолтов с тем же началом.
    if type(normalized) == "string" and #normalized == 1 then
      local match = nil
      for defaultKey in pairs(defaults) do
        if type(defaultKey) == "string" and defaultKey:sub(1, 1) == normalized then
          if match ~= nil then
            return nil
          end
          match = defaultKey
        end
      end
      return match
    end
    return nil
  end

  local merged = {}
  for key, value in pairs(defaults) do
    merged[key] = value
  end
  for key, value in pairs(props or {}) do
    local resolvedKey = resolveDefaultKey(key)
    if resolvedKey == nil then
      local known = {}
      for defaultKey in pairs(defaults) do
        table.insert(known, tostring(defaultKey))
      end
      table.sort(known)
      error(
        "неизвестный props: " .. tostring(key)
          .. " (normal: " .. tostring(normalizeKey(key))
          .. ", known: " .. table.concat(known, ", ") .. ")",
        3
      )
    end
    merged[resolvedKey] = value
  end
  return merged
end

-- Цвет из props: имя роли Theme или литерал.
function Component.color(value)
  return require("ui.Theme").resolve(value)
end

function Component.join(parts)
  return table.concat(parts)
end

-- Данные (имена, бэкграунды) уходят в XML-атрибуты и текстовые узлы, поэтому
-- их надо экранировать. Слоты с готовой разметкой — наоборот, нельзя.
function Component.escape(text)
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

return Component
