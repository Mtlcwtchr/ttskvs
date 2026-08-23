-- Содержимое видно только в режиме просмотра.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")

local ViewOnly = {}

ViewOnly.defaults = { content = "" }

function ViewOnly.render(props)
  local p = Component.props(ViewOnly.defaults, props)
  if Common.isWizard() then
    return ""
  end
  return p.content
end

return ViewOnly
