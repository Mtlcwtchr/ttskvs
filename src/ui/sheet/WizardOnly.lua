-- Содержимое видно только в режиме правки (визарде).
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")

local WizardOnly = {}

WizardOnly.defaults = { content = "" }

function WizardOnly.render(props)
  local p = Component.props(WizardOnly.defaults, props)
  if not Common.isWizard() then
    return ""
  end
  return p.content
end

return WizardOnly
