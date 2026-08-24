local Component = require("ui.Component")
local Badge = require("ui.components.Badge")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Tile = {}

Tile.defaults = {
  label = "",
  content = "",
  sub = "",
  width = "fill",
  height = "fill",
  padding = "3 3 4 6",
  color = Theme.bgPanelLight,
  labelColor = Theme.labelGold,
  labelFontSize = 8,
  labelHeight = 11,
  subColor = Theme.textCream,
  subBorderColor = Theme.gold,
  subWidth = 40,
}

function Tile.render(props)
  local p = Component.props(Tile.defaults, props)
  local sub = tostring(p.sub or "")
  local subBlock = ""
  if sub ~= "" then
    subBlock = Badge.render({
      value = Component.escape(sub),
      width = p.subWidth,
      textColor = p.subColor,
      borderColor = p.subBorderColor,
    })
  end
  return Component.render(Templates.Tile, {
    LABEL = p.label,
    VALUE = p.content,
    SUB_BLOCK = subBlock,
    WIDTH = p.width,
    HEIGHT = p.height,
    PADDING = p.padding,
    COLOR = Component.color(p.color),
    LABEL_COLOR = Component.color(p.labelColor),
    LABEL_FONT_SIZE = p.labelFontSize,
    LABEL_HEIGHT = p.labelHeight,
  })
end

return Tile
