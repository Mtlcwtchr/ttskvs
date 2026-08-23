-- Реальной интеграции с TTS Turns API пока нет — заглушка, чтобы UI-слой уже
-- сейчас звал сервис (а не решал сам, что значит "закончить ход").
local TurnService = {}

function TurnService.endTurn()
  printToAll("Ход передан.", { 0.79, 0.66, 0.29 })
end

return TurnService
