local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local PortraitContent = {}

PortraitContent.defaults = {
  initial = "?",
  hp = "",
  initialColor = "goldBright",
  hpColor = "textCream",
}

function PortraitContent.render(props)
  local p = Component.props(PortraitContent.defaults, props)
  return Component.render(Templates.PortraitContent, {
    INITIAL = p.initial,
    HP = p.hp,
    INITIAL_COLOR = Component.color(p.initialColor),
    HP_COLOR = Component.color(p.hpColor),
  })
end

return PortraitContent
