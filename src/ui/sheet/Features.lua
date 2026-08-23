-- Абилки и заклинания: в просмотре сгруппированы по типу действия, в визарде —
-- строки «название + тип» плюс пустая для добавления.
local Caption = require("ui.components.Caption")
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local Features = {}

local GROUPS = {
  { caption = "ДЕЙСТВИЕ", types = { action = true } },
  { caption = "БОНУС", types = { bonus = true, bonus_action = true } },
  { caption = "РЕАКЦИЯ", types = { reaction = true } },
}

Features.defaults = {}

local function groupOf(actionType)
  for index, group in ipairs(GROUPS) do
    if group.types[actionType] then
      return index
    end
  end
  return #GROUPS + 1
end

function Features.render()
  local character = Common.character()
  local features = character.abilities or {}
  local rows = {}

  if Common.isWizard() then
    for index = 1, #features + 1 do
      table.insert(rows, Component.render(Templates.FeatureEditRow, {
        NAME = Field.render({ name = "field_feat_" .. index .. "_name", width = 220, height = 24 }),
        TYPE = Field.render({ name = "field_feat_" .. index .. "_type", width = 110, height = 24 }),
        DESC = Field.render({ name = "field_feat_" .. index .. "_desc", width = 340, height = 24 }),
      }))
    end
    return Component.join(rows)
  end

  local buckets = {}
  for index = 1, #GROUPS + 1 do
    buckets[index] = {}
  end
  for _, feature in ipairs(features) do
    local bucket = buckets[groupOf(feature.actionType or "action")]
    table.insert(bucket, feature.name or feature.id or "")
  end

  for index = 1, #GROUPS + 1 do
    local names = buckets[index]
    if #names > 0 then
      local caption = (index <= #GROUPS) and GROUPS[index].caption or "ПРОЧЕЕ"
      table.insert(rows, Caption.render({ text = caption }))
      for _, name in ipairs(names) do
        local description = ""
        for _, feature in ipairs(features) do
          if (feature.name or feature.id or "") == name then
            description = feature.description or ""
            break
          end
        end
        table.insert(rows, Component.render(Templates.FeatureRow, {
          NAME = Component.escape(name),
          DESC = Component.escape(description),
        }))
      end
    end
  end

  table.insert(rows, Caption.render({ text = "ЯЧЕЙКИ ЗАКЛИНАНИЙ" }))
  local slots = character.spellSlots or {}
  table.insert(rows, Label.render({
    text = #slots > 0 and tostring(#slots) or "—",
    fontSize = 12,
    color = "textMuted",
  }))
  return Component.join(rows)
end

return Features
