-- Заметки листа. В 4A это два блока рядом: PROFICIENCIES & LORE (владения,
-- языки, происхождение) и TABLE NOTES (характер и заметки за столом), поэтому
-- тег принимает group="lore"|"notes" и отдаёт только свою половину.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local CustomGroups = {}

CustomGroups.defaults = { group = "notes" }

-- Порядок и подписи — лейаут, поэтому живут здесь, а не в реестре полей.
local GROUPS = {
  lore = {
    { title = "ЯЗЫКИ И ВЛАДЕНИЯ", field = nil, source = "otherProficiencies" },
    { title = "ПРОИСХОЖДЕНИЕ", field = "field_background" },
  },
  notes = {
    { title = "ЧЕРТЫ", field = "field_traits" },
    { title = "ИДЕАЛЫ", field = "field_ideals" },
    { title = "ПРИВЯЗАННОСТИ", field = "field_bonds" },
    { title = "СЛАБОСТИ", field = "field_flaws" },
  },
}

-- В колонке заметок ~26 символов в строке при кегле 12 — отсюда высота блока.
local CHARS_PER_LINE = 22
local LINE_HEIGHT = 15

local function row(title, text)
  return Component.render(Templates.CustomGroupRow, {
    TITLE = Component.escape(title),
    DESCRIPTION = Component.escape(text),
    TEXT_HEIGHT = LINE_HEIGHT * math.min(6, Common.textLines(text, CHARS_PER_LINE)),
  })
end

function CustomGroups.render(props)
  local p = Component.props(CustomGroups.defaults, props)
  local character = Common.character()
  local entries = GROUPS[p.group]
  if entries == nil then
    error("CustomGroups: неизвестная группа '" .. tostring(p.group) .. "' (lore/notes)", 0)
  end
  local rows = {}

  if Common.isWizard() then
    for _, entry in ipairs(entries) do
      if entry.field ~= nil then
        table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
          HEIGHT = 42,
          TITLE_FIELD = Label.render({
            text = Component.escape(entry.title), alignment = "MiddleLeft",
            fontSize = 9, color = "textMuted", height = "fill",
          }),
          DESC_FIELD = Field.render({ name = entry.field, height = "fill", fontSize = 11 }),
        }))
      end
    end
    if p.group == "notes" then
      local custom = character.customGroups or {}
      for index = 1, #custom + 1 do
        table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
          HEIGHT = 42,
          TITLE_FIELD = Field.render({ name = "field_custom_" .. index .. "_title", height = "fill", fontSize = 10 }),
          DESC_FIELD = Field.render({ name = "field_custom_" .. index .. "_desc", height = "fill", fontSize = 11 }),
        }))
      end
    end
    return Component.join(rows)
  end

  for _, entry in ipairs(entries) do
    local text
    if entry.source == "otherProficiencies" then
      text = table.concat(character.otherProficiencies or {}, ", ")
    else
      text = tostring(Common.value(entry.field) or "")
    end
    if text ~= "" then
      table.insert(rows, row(entry.title, text))
    end
  end

  if p.group == "notes" then
    for _, item in ipairs(character.customGroups or {}) do
      local text = tostring(item.description or "")
      if text ~= "" then
        table.insert(rows, row(item.title or "ЗАМЕТКА", text))
      end
    end
  end

  if #rows == 0 then
    return Label.render({ text = "—", fontSize = 12, color = "textFaint", height = 20 })
  end
  return Component.join(rows)
end

return CustomGroups
