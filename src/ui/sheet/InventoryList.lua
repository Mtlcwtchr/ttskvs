-- Сумка: сетка ячеек 7 в ряд, как в 4A. Числа рядов и ячеек — здесь, размеры —
-- в разметке (ячейки делят ширину строки поровну).
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local InventoryList = {}

InventoryList.defaults = {}

local CELLS_PER_ROW = 7
local ROWS = 3
local ROW_HEIGHT = 46

function InventoryList.render()
  local inventory = Common.character().inventory or {}
  local rows = {}
  local cells = {}
  local total = CELLS_PER_ROW * ROWS

  for index = 1, total do
    local item = inventory[index]
    local filled = item ~= nil and tostring(item.name or "") ~= ""
    local content

    if Common.isWizard() then
      content = Component.join({
        Field.render({ name = "field_item_" .. index .. "_name", height = "fill", fontSize = 9, alignment = "MiddleCenter" }),
        Field.render({ name = "field_item_" .. index .. "_qty", height = "fill", fontSize = 9, alignment = "MiddleCenter" }),
      })
    elseif filled then
      content = Component.join({
        Label.render({
          text = Component.escape(item.name), fontSize = 9, alignment = "UpperCenter",
          color = "slotLabel", height = "fill",
        }),
        Label.render({
          text = "×" .. tostring(item.qty or 1), fontSize = 9, alignment = "LowerRight",
          color = "goldBright", height = 11,
        }),
      })
    else
      content = Label.render({ text = "", fontSize = 9, color = "textFaint", height = "fill" })
    end

    table.insert(cells, Component.render(Templates.InventoryCell, {
      WIDTH = "fill",
      HEIGHT = "fill",
      COLOR = Component.color(filled and "bgTile" or "bgEmpty"),
      BORDER_COLOR = Component.color(filled and "brass" or "borderFaint"),
      VALUE = content,
    }))
  end

  for rowStart = 1, total, CELLS_PER_ROW do
    local rowCells = {}
    for i = rowStart, rowStart + CELLS_PER_ROW - 1 do
      table.insert(rowCells, cells[i])
    end
    table.insert(rows, Component.render(Templates.InventoryGridRow, {
      HEIGHT = ROW_HEIGHT,
      GAP = 5,
      CELLS = Component.join(rowCells),
    }))
  end

  return Component.join(rows)
end

return InventoryList
