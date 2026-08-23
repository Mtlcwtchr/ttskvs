local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Section = {}

Section.defaults = {
  title = "",
  width = 420,
  height = 200,
  color = Theme.bgTile,
  titleColor = Theme.labelGold,
  titleFontSize = 9,
  titleAlignment = "MiddleCenter",
  titleHeight = 28,
  headerSpacing = 2,
  contentPadding = "4 6 6 6",
  spacing = 4,
  content = "",
}

function Section.render(props)
  local p = Component.props(Section.defaults, props)
  local titleHeight = math.max(0, tonumber(p.titleHeight) or 0)
  local headerSpacing = math.max(0, tonumber(p.headerSpacing) or 0)
  local contentHeight = math.max(0, (tonumber(p.height) or 0) - titleHeight - headerSpacing)
  return Component.render(Templates.Section, {
    TITLE = p.title,
    WIDTH = p.width,
    HEIGHT = p.height,
    TITLE_HEIGHT = titleHeight,
    HEADER_SPACING = headerSpacing,
    CONTENT_HEIGHT = contentHeight,
    CONTENT_PADDING = p.contentPadding,
    CONTENT_SPACING = p.spacing,
    COLOR = Component.color(p.color),
    TITLE_COLOR = Component.color(p.titleColor),
    TITLE_FONT_SIZE = p.titleFontSize,
    TITLE_ALIGNMENT = p.titleAlignment,
    CONTENT = p.content,
  })
end

return Section
