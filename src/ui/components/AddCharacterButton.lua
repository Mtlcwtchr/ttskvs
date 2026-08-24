-- «Открытое место» в рейке: данных не требует, вся описана разметкой.
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local AddCharacterButton = {}

AddCharacterButton.defaults = { size = 72 }

function AddCharacterButton.render(props)
  local p = Component.props(AddCharacterButton.defaults, props)
  return Component.render(Templates.AddCharacterButton, { SIZE = p.size })
end

return AddCharacterButton
