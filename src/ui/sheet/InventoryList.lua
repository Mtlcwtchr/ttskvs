-- Инвентарь: предметы с количеством, языки/владения, вес.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Line = require("ui.components.Line")
local Templates = require("ui.generated.Templates")

local InventoryList = {}

InventoryList.defaults = {}

function InventoryList.render()
  local inventory = Common.character().inventory or {}
  local rows = {}
  local cells = {}
  local cellsPerRow = 6
  local totalCells = 24
  local cellWidth = 76
  local cellHeight = 56

  for index = 1, totalCells do
    local content
    local item = inventory[index]
    if Common.isWizard() then
      content = Component.join({
        Field.render({ name = "field_item_" .. index .. "_name", width = 66, height = 24, fontSize = 11 }),
        Field.render({ name = "field_item_" .. index .. "_qty", width = 66, height = 20, fontSize = 10 }),
      })
    elseif item ~= nil and tostring(item.name or "") ~= "" then
      content = Component.join({
        Label.render({ text = Component.escape(item.name), fontSize = 10, alignment = "UpperLeft", color = "textBody" }),
        Label.render({ text = "x" .. tostring(item.qty or 1), fontSize = 10, alignment = "LowerRight", color = "goldBright" }),
      })
    else
      content = Label.render({ text = "", fontSize = 10, color = "textMuted" })
    end

    table.insert(cells, Component.render(Templates.InventoryCell, {
      WIDTH = cellWidth,
      HEIGHT = cellHeight,
      VALUE = content,
    }))
  end

  for rowStart = 1, totalCells, cellsPerRow do
    local rowCells = {}
    for i = rowStart, rowStart + cellsPerRow - 1 do
      table.insert(rowCells, cells[i])
    end
    table.insert(rows, Line.render({
      fit = "fixed",
      spacing = 4,
      childAlignment = "UpperLeft",
      content = Component.join(rowCells),
    }))
  end

  return Component.join(rows)
end

return InventoryList
