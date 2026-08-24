-- Рендер-подписчик: слушает изменения состояния и перерисовывает Global UI.
-- Состояние не хранит и не мутирует — только state -> XML.
local PartyService = require("core.PartyService")
local UIBuilder = require("ui.builders.UIBuilder")

local HUDView = {}

local mounted = false
local lastAssetsKey = ""

local function render(state)
  -- Собираем ассеты из portrait/silhouette URL всех персонажей.
  -- setCustomAssets вызываем только когда набор URL реально изменился.
  local assets = {}
  local keyParts = {}
  for _, character in ipairs(state.party or {}) do
    local portrait = character.portrait or ""
    if portrait ~= "" then
      table.insert(assets, { name = "portrait_" .. character.id, url = portrait })
      table.insert(keyParts, "p" .. character.id .. "=" .. portrait)
    end
    local silhouette = character.silhouette or ""
    if silhouette ~= "" then
      table.insert(assets, { name = "silhouette_" .. character.id, url = silhouette })
      table.insert(keyParts, "s" .. character.id .. "=" .. silhouette)
    end
  end
  local assetsKey = table.concat(keyParts, "|")
  if assetsKey ~= lastAssetsKey then
    if #assets > 0 then
      UI.setCustomAssets(assets)
    end
    lastAssetsKey = assetsKey
  end

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
