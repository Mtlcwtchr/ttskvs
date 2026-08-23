local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local StatBar = {}

StatBar.defaults = {
  title = "",
  content = "",
  width = 195,
  height = 110,
  color = Theme.bgTile,
  titleColor = Theme.labelGold,
  trackColor = Theme.hpRedDark,
  fillColor = Theme.hpRed,
  -- Доля 0..1; в пиксели переводим здесь, процентов TTS XML не понимает.
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
    COLOR = Component.color(p.color),
    TITLE_COLOR = Component.color(p.titleColor),
    TRACK_COLOR = Component.color(p.trackColor),
    FILL_COLOR = Component.color(p.fillColor),
    FILL_WIDTH = math.floor((p.width - 16) * ratio),
  })
end

return StatBar
