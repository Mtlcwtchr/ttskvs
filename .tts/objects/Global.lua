local PartyService = require("core.PartyService")
local HUDView = require("ui.HUDView")
require("ui.HUDEvents") -- регистрирует глобальные onClick-колбэки TTS

function onLoad()
  HUDView.init(PartyService)
  PartyService.load()
end

function onUpdate()
end
