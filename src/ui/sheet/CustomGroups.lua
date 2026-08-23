local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local CustomGroups = {}

CustomGroups.defaults = {}

local function push(rows, title, description)
  local text = tostring(description or "")
  if text == "" then
    return
  end
  table.insert(rows, Component.render(Templates.CustomGroupRow, {
    TITLE = Component.escape(title),
    DESCRIPTION = Component.escape(text),
  }))
end

function CustomGroups.render()
  local character = Common.character()
  local rows = {}

  if Common.isWizard() then
    table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
      TITLE_FIELD = Label.render({ text = "LORE", alignment = "MiddleLeft", color = "goldDim" }),
      DESC_FIELD = Field.render({ name = "field_background", width = 260, height = 24 }),
    }))
    table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
      TITLE_FIELD = Label.render({ text = "LANGUAGES", alignment = "MiddleLeft", color = "goldDim" }),
      DESC_FIELD = Field.render({ name = "field_other_proficiencies", width = 260, height = 24 }),
    }))
    table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
      TITLE_FIELD = Label.render({ text = "TRAITS", alignment = "MiddleLeft", color = "goldDim" }),
      DESC_FIELD = Field.render({ name = "field_traits", width = 260, height = 24 }),
    }))
    table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
      TITLE_FIELD = Label.render({ text = "IDEALS", alignment = "MiddleLeft", color = "goldDim" }),
      DESC_FIELD = Field.render({ name = "field_ideals", width = 260, height = 24 }),
    }))
    table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
      TITLE_FIELD = Label.render({ text = "BONDS", alignment = "MiddleLeft", color = "goldDim" }),
      DESC_FIELD = Field.render({ name = "field_bonds", width = 260, height = 24 }),
    }))
    table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
      TITLE_FIELD = Label.render({ text = "FLAWS", alignment = "MiddleLeft", color = "goldDim" }),
      DESC_FIELD = Field.render({ name = "field_flaws", width = 260, height = 24 }),
    }))

    local custom = character.customGroups or {}
    for index = 1, #custom + 1 do
      table.insert(rows, Component.render(Templates.CustomGroupEditRow, {
        TITLE_FIELD = Field.render({ name = "field_custom_" .. index .. "_title", width = 160, height = 24 }),
        DESC_FIELD = Field.render({ name = "field_custom_" .. index .. "_desc", width = 260, height = 24 }),
      }))
    end
    return Component.join(rows)
  end

  push(rows, "LORE", Common.value("field_background"))
  push(rows, "LANGUAGES", table.concat(character.otherProficiencies or {}, ", "))
  push(rows, "TRAITS", Common.value("field_traits"))
  push(rows, "IDEALS", Common.value("field_ideals"))
  push(rows, "BONDS", Common.value("field_bonds"))
  push(rows, "FLAWS", Common.value("field_flaws"))

  for _, item in ipairs(character.customGroups or {}) do
    push(rows, item.title or "ЗАМЕТКА", item.description or "")
  end

  if #rows == 0 then
    return Label.render({ text = "—", fontSize = 12, color = "textMuted" })
  end
  return Component.join(rows)
end

return CustomGroups
