-- Тонкий entrypoint: инициализирует слои и проксирует глобальные TTS-колбэки.
local PartyService = require("core.PartyService")
local HUDEvents = require("ui.HUDEvents")
local HUDView = require("ui.HUDView")

local CUSTOM_ASSETS = {
  {
    name = "CormorantSC",
    url = "https://raw.githubusercontent.com/Mtlcwtchr/ttskvs/main/assets/fonts/bundles/osx/kvs_font_cormorant_sc.unity3d",
  },
  {
    name = "CormorantGaramond",
    url = "https://raw.githubusercontent.com/Mtlcwtchr/ttskvs/main/assets/fonts/bundles/osx/kvs_font_cormorant_garamond.unity3d",
  },
}

function onLoad()
  UI.setCustomAssets(CUSTOM_ASSETS)
  HUDView.mount()
  PartyService.load(function()
    HUDView.renderNow()
  end)
end

function selectCharacter(player, value, id)
  HUDEvents.selectCharacter(player, value, id)
end

function createCharacter(player, value, id)
  HUDEvents.createCharacter(player, value, id)
end

function startWizard(player, value, id)
  HUDEvents.startWizard(player, value, id)
end

function finishWizard(player, value, id)
  HUDEvents.finishWizard(player, value, id)
end

function closeSheet(player, value, id)
  HUDEvents.closeSheet(player, value, id)
end

function deleteCharacter(player, value, id)
  HUDEvents.deleteCharacter(player, value, id)
end

function onCharacterFieldChanged(player, value, id)
  HUDEvents.onCharacterFieldChanged(player, value, id)
end
