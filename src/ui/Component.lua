-- Движок компонентов: подстановка {{KEY}} в разметку + слияние props с
-- дефолтами. Ничего не знает ни про конкретные компоненты, ни про TTS —
-- чистые функции над строками.
local Component = {}

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
  local merged = {}
  for key, value in pairs(defaults) do
    merged[key] = value
  end
  for key, value in pairs(props or {}) do
    if defaults[key] == nil then
      local known = {}
      for defaultKey in pairs(defaults) do
        table.insert(known, tostring(defaultKey))
      end
      table.sort(known)
      error("неизвестный props: " .. tostring(key) .. ", known: " .. table.concat(known, ", "), 3)
    end
    merged[key] = value
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

function Component.escape(text)
  return text
end

return Component
