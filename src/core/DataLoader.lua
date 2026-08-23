local DataLoader = {}

local PARTY_URL = nil

function DataLoader.setPartyUrl(url)
  PARTY_URL = url
end

function DataLoader.loadParty(callback)
  if PARTY_URL == nil or PARTY_URL == "" then
    callback({})
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
