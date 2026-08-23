-- Данных не требует: вся кнопка описана разметкой.
local Markup = require("ui.Markup")
local Templates = require("ui.generated.Templates")

local AddCharacterButton = {}

AddCharacterButton.defaults = {}

function AddCharacterButton.render()
  return Markup.expand(Templates.AddCharacterButton)
end

return AddCharacterButton
