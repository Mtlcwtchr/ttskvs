local Component = require("ui.Component")
local Note = require("ui.components.Note")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Tile = {}

Tile.defaults = {
  label = "",
  content = "",
  sub = "",
  width = 61,
  height = 62,
  color = Theme.bgPanelLight,
  labelColor = Theme.labelGold,
  subColor = Theme.textMuted,
}

function Tile.render(props)
  local p = Component.props(Tile.defaults, props)
  local sub = tostring(p.sub or "")
  local subBlock = ""
  if sub ~= "" then
    subBlock = Note.render({
      text = Component.escape(sub),
      color = p.subColor,
    })
  end
  return Component.render(Templates.Tile, {
    LABEL = p.label,
    VALUE = p.content,
    SUB_BLOCK = subBlock,
    WIDTH = p.width,
    HEIGHT = p.height,
    COLOR = Component.color(p.color),
    LABEL_COLOR = Component.color(p.labelColor),
  })
end

return Tile
