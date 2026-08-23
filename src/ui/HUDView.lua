-- Рендер-подписчик: слушает изменения состояния и перерисовывает Global UI.
-- Состояние не хранит и не мутирует — только state -> XML.
local PartyService = require("core.PartyService")
local UIBuilder = require("ui.builders.UIBuilder")

local HUDView = {}

local mounted = false

local function render(state)
  local xml = UIBuilder.buildMainUI(
    state.party,
    state.selectedCharacterId,
    state.sheetVisible,
    state.sheetMode
  )
  UI.setXml(xml)
  print("[KVS] UI: " .. #xml .. " символов, режим " .. tostring(state.sheetMode))
end

function HUDView.mount()
  if mounted then
    return
  end
  PartyService.subscribe(render)
  mounted = true
end

function HUDView.renderNow()
  render(PartyService.getState())
end

return HUDView
