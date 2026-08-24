-- Заметки листа. Две группы:
-- lore — фиксированные блоки (языки, происхождение)
-- notes — полностью динамический список title+description с add/delete
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local CustomGroups = {}

CustomGroups.defaults = { group = "notes" }

-- Lore — фиксированные блоки
local LORE = {
  { title = "ЯЗЫКИ И ВЛАДЕНИЯ", field = nil, source = "otherProficiencies" },
  { title = "ПРОИСХОЖДЕНИЕ", field = "field_background" },
}

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
  local rows = {}

  if p.group == "lore" then
    -- Lore: фиксированные блоки (как раньше)
    if Common.isWizard() then
      for _, entry in ipairs(LORE) do
        if entry.field ~= nil then
          table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
            HEIGHT = 42,
            TITLE_FIELD = Label.render({
              text = Component.escape(entry.title), alignment = "MiddleLeft",
              fontSize = 9, color = "textMuted", height = "fill",
            }),
            DESC_FIELD = Field.render({ name = entry.field, height = "fill", fontSize = 11 }),
            DELETE_BUTTON = "",
          }))
        end
      end
    else
      for _, entry in ipairs(LORE) do
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
    end

  else
    -- Notes: динамический список из customGroups
    local custom = character.customGroups or {}

    if Common.isWizard() then
      for index = 1, #custom do
        table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
          HEIGHT = 56,
          TITLE_FIELD = Field.render({
            name = "field_custom_" .. index .. "_title",
            height = "fill", fontSize = 10,
            placeholder = "Название",
          }),
          DESC_FIELD = Field.render({
            name = "field_custom_" .. index .. "_desc",
            height = "fill", fontSize = 11,
            placeholder = "Описание",
          }),
          DELETE_BUTTON = '<Button id="delete_note_' .. index .. '" width="fill" height="fill"'
            .. ' colors="buttonStates" textColor="buttonText"'
            .. ' textAlignment="MiddleCenter" fontSize="12" onClick="deleteNote">✕</Button>',
        }))
      end
      -- Кнопка «+» для добавления новой заметки
      table.insert(rows,
        '<Box width="fill" height="24">'
        .. '<Button id="add_note" width="fill" height="fill"'
        .. ' colors="buttonStates" textColor="buttonText"'
        .. ' textAlignment="MiddleCenter" fontSize="14" onClick="addNote">+ Заметка</Button>'
        .. '</Box>')
    else
      for _, item in ipairs(custom) do
        local title = tostring(item.title or "")
        local text = tostring(item.description or "")
        if title ~= "" or text ~= "" then
          table.insert(rows, row(title ~= "" and title or "ЗАМЕTКА", text))
        end
      end
    end
  end

  if #rows == 0 then
    return Label.render({ text = "—", fontSize = 12, color = "textFaint", height = 20 })
  end
  return Component.join(rows)
end

return CustomGroups
