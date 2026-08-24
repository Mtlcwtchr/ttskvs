-- Способности и обеты (4A, блок ABILITIES & OATHS): значок, название,
-- описание. В визарде — строки правки, на одну больше числа способностей:
-- заполнили пустую — появилась новая.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Templates = require("ui.generated.Templates")

local Features = {}

Features.defaults = {}

-- Значок в 4A — трёхбуквенная метка на плитке. Берём первые буквы названия:
-- строка в Lua — байты, поэтому символы отбираем по ведущему байту.
local function iconOf(name)
  local text = tostring(name or "")
  local letters = {}
  for character in text:gmatch("[\1-\127\194-\244][\128-\191]*") do
    if character:match("%s") == nil then
      table.insert(letters, character)
    end
    if #letters == 3 then
      break
    end
  end
  if #letters == 0 then
    return "—"
  end
  return table.concat(letters):upper()
end

function Features.render()
  local features = Common.character().abilities or {}
  local rows = {}

  if Common.isWizard() then
    for index = 1, #features + 1 do
      table.insert(rows, Component.render(Templates.FeatureEditRow, {
        HEIGHT = 58,
        NAME = Field.render({ name = "field_feat_" .. index .. "_name", height = "fill", fontSize = 12 }),
        TYPE = Field.render({ name = "field_feat_" .. index .. "_type", height = "fill", fontSize = 12 }),
        DESC = Field.render({ name = "field_feat_" .. index .. "_desc", height = "fill", fontSize = 11 }),
      }))
    end
    return Component.join(rows)
  end

  if #features == 0 then
    return Component.render(Templates.FeatureRow, {
      HEIGHT = 30,
      ICON = "—",
      NAME = "Способностей нет",
      DESC = "",
    })
  end

  -- В блоке способностей ~52 символа в строке при кегле 11.
  for _, feature in ipairs(features) do
    local name = feature.name or feature.id or ""
    local lines = math.min(4, Common.textLines(feature.description, 52))
    table.insert(rows, Component.render(Templates.FeatureRow, {
      HEIGHT = math.max(30, 18 + lines * 14),
      ICON = Component.escape(iconOf(name)),
      NAME = Component.escape(name),
      DESC = Component.escape(feature.description or ""),
    }))
  end
  return Component.join(rows)
end

return Features
