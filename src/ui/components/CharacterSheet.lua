-- Лист персонажа как тег: рисуется, только если он открыт и есть кого рисовать.
-- Сама страница — layout/CharacterSheet.xml.
local Markup = require("ui.Markup")
local Templates = require("ui.generated.Templates")

local CharacterSheet = {}

CharacterSheet.defaults = {}

function CharacterSheet.render()
  local context = Markup.context()
  if not context.sheetVisible or context.character == nil then
    return ""
  end
  return Markup.expand(Templates.CharacterSheet)
end

return CharacterSheet
