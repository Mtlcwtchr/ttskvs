-- Общее для тегов листа персонажа: доступ к контексту рендера и арифметика
-- D&D. Отдельный модуль, чтобы каждый тег не тащил по пять require.
local CharacterFields = require("core.CharacterFields")
local Markup = require("ui.Markup")

local Common = {}

Common.VIEW = "view"
Common.WIZARD = "wizard"

function Common.character()
  return Markup.context().character
end

function Common.mode()
  return Markup.context().mode or Common.VIEW
end

function Common.isWizard()
  return Common.mode() == Common.WIZARD
end

function Common.value(fieldId)
  return CharacterFields.get(Common.character(), fieldId)
end

function Common.kind(fieldId)
  return CharacterFields.kind(fieldId)
end

function Common.signed(value)
  local n = math.floor(tonumber(value) or 0)
  if n >= 0 then
    return "+" .. tostring(n)
  end
  return tostring(n)
end

function Common.modifier(score)
  return math.floor(((tonumber(score) or 10) - 10) / 2)
end

-- Сколько строк займёт текст в клетке, где помещается charsPerLine символов.
-- Меряем СИМВОЛЫ, а не байты: в кириллице символ — два байта, и #text врал бы
-- вдвое. Это оценка: точную ширину строки в песочнице не измерить, поэтому
-- ошибку добирает автоподбор кегля (Layout дописывает его каждому <Text>).
function Common.textLines(text, charsPerLine)
  local characters = 0
  for _ in tostring(text or ""):gmatch("[\1-\127\194-\244][\128-\191]*") do
    characters = characters + 1
  end
  if characters == 0 then
    return 1
  end
  return math.max(1, math.ceil(characters / math.max(1, charsPerLine)))
end

function Common.hasProficiency(list, key)
  for _, item in ipairs(list or {}) do
    if item == key then
      return true
    end
  end
  return false
end

return Common
