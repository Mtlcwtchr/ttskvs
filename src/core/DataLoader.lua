-- Единственное место, которое знает, откуда берутся данные.
-- Остальной код всегда зовёт DataLoader.loadParty(callback) и получает массив
-- персонажей — не важно, пришёл он по сети или из MockData (сгенерирован из
-- data/characters/*.json, см. tools/tts_bridge.py sync-mock).
local MockData = require("core.MockData")

local DataLoader = {}

-- TODO: когда JSON захостен (например GitHub raw), выставить USE_MOCK = false
-- и указать реальный PARTY_URL.
local USE_MOCK = true
local PARTY_URL = "https://example.com/kvs-data/characters.json"

function DataLoader.loadParty(callback)
  if USE_MOCK then
    callback(MockData)
    return
  end

  WebRequest.get(PARTY_URL, function(request)
    if request.is_error then
      printToAll("[DataLoader] Ошибка загрузки party: " .. request.error, { 1, 0.3, 0.3 })
      callback({})
      return
    end

    local ok, decoded = pcall(JSON.decode, request.text)
    if not ok or decoded == nil then
      printToAll("[DataLoader] Не удалось разобрать JSON партии", { 1, 0.3, 0.3 })
      callback({})
      return
    end

    callback(decoded)
  end)
end

return DataLoader
