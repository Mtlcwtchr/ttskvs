-- Секция листа. Высоту контентной зоны не считаем: заголовок фиксирован, зона
-- содержимого объявлена height="fill", остаток делит Layout.
-- titleAt="bottom" — подпись под содержимым (так в 4A подписан список навыков).
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local Section = {}

Section.defaults = {
  title = "",
  width = "fill",
  height = "fill",
  color = Theme.bgPanel,
  titleColor = Theme.labelGold,
  titleFontSize = 9,
  titleAlignment = "MiddleLeft",
  titleHeight = 14,
  titleAt = "top",
  padding = "10 10 8 8",
  headerGap = 6,
  gap = 4,
  content = "",
}

function Section.render(props)
  local p = Component.props(Section.defaults, props)
  local template = (p.titleAt == "bottom") and Templates.SectionFooter or Templates.Section
  return Component.render(template, {
    TITLE = p.title,
    WIDTH = p.width,
    HEIGHT = p.height,
    TITLE_HEIGHT = p.titleHeight,
    PADDING = p.padding,
    HEADER_GAP = p.headerGap,
    CONTENT_GAP = p.gap,
    COLOR = Component.color(p.color),
    TITLE_COLOR = Component.color(p.titleColor),
    TITLE_FONT_SIZE = p.titleFontSize,
    TITLE_ALIGNMENT = p.titleAlignment,
    CONTENT = p.content,
  })
end

return Section
