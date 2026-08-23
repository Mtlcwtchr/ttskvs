-- Весь экран описан разметкой (ui/layout/MainUI.xml). Здесь только контекст
-- рендера: кто в партии, кто выбран, открыт ли лист и в каком режиме.
-- Дальше теги сами достают данные — см. ui/Markup.lua и ui/components/.
local Markup = require("ui.Markup")
local Templates = require("ui.generated.Templates")

local UIBuilder = {}

UIBuilder.VIEW = "view"
UIBuilder.WIZARD = "wizard"

local function findById(party, characterId)
  for _, character in ipairs(party or {}) do
    if character.id == characterId then
      return character
    end
  end
  return nil
end

function UIBuilder.buildMainUI(party, selectedCharacterId, sheetVisible, sheetMode)
  return Markup.render(Templates.MainUI, {
    party = party or {},
    selectedCharacterId = selectedCharacterId,
    sheetVisible = sheetVisible == true,
    mode = sheetMode or UIBuilder.VIEW,
    character = findById(party, selectedCharacterId),
  })
end

return UIBuilder
