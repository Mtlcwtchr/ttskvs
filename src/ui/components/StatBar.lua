local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local StatBar = {}

StatBar.defaults = {
  title = "",
  content = "",
  width = "fill",
  height = 46,
  padding = "10 10 7 7",
  color = Theme.bgPanel,
  titleColor = Theme.labelGold,
  titleFontSize = 9,
  titleHeight = "fill",
  valueWidth = 76,
  trackColor = Theme.bgTrack,
  trackHeight = 12,
  fillColor = Theme.hpRed,
  -- Доля 0..1. В разметку уходит процентом от дорожки: пиксельная арифметика
  -- от ширины блока была ещё одним местом, где размер дублировался руками.
  ratio = 0,
}

function StatBar.render(props)
  local p = Component.props(StatBar.defaults, props)
  local ratio = math.max(0, math.min(1, tonumber(p.ratio) or 0))

  return Component.render(Templates.StatBar, {
    TITLE = p.title,
    VALUE = p.content,
    WIDTH = p.width,
    HEIGHT = p.height,
    PADDING = p.padding,
    COLOR = Component.color(p.color),
    TITLE_COLOR = Component.color(p.titleColor),
    TITLE_FONT_SIZE = p.titleFontSize,
    TITLE_HEIGHT = p.titleHeight,
    VALUE_WIDTH = p.valueWidth,
    TRACK_COLOR = Component.color(p.trackColor),
    TRACK_HEIGHT = p.trackHeight,
    FILL_COLOR = Component.color(p.fillColor),
    FILL_PERCENT = string.format("%d%%", math.floor(ratio * 100 + 0.5)),
  })
end

return StatBar
