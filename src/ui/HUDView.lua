-- Реактивный рендер: подписывается на PartyService и на КАЖДОЕ изменение
-- модели перерисовывает весь UI.setXmlTable целиком (render = f(state)).
-- Сам не мутирует состояние и не является источником событий — только читает.
local Builders = require("ui.Builders")

local HUDView = {}

local function render(state)
  local root = { Builders.partyBar(state.party, state.selectedCharacterId) }
  local ownerColor = state.lastPlayerColor or "White"

  if state.selectedCharacterId ~= nil then
    local selected = state.partyById[state.selectedCharacterId]
    if selected ~= nil then
      table.insert(root, Builders.hotbar(selected, ownerColor))
    end
  end

  if state.openCharacterId ~= nil then
    local opened = state.partyById[state.openCharacterId]
    if opened ~= nil then
      table.insert(root, Builders.characterPanel(opened, ownerColor, state.activeTab))
    end
  end

  UI.setXmlTable(root)
end

function HUDView.init(partyService)
  partyService.subscribe(render)
end

return HUDView
