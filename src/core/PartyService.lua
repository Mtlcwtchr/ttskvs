-- Модель партии + вся логика взаимодействия с ней. UI не мутирует это
-- состояние напрямую нигде — только через методы этого сервиса. UI-слой
-- узнаёт об изменениях через store:subscribe (см. ui/HUDView.lua).
local Store = require("core.Store")
local DataLoader = require("core.DataLoader")

local store = Store.new({
  party = {},
  partyById = {},
  selectedCharacterId = nil,
  openCharacterId = nil,
  lastPlayerColor = "White",
})

local PartyService = {}

function PartyService.subscribe(listener)
  store:subscribe(listener)
end

function PartyService.getState()
  return store:getState()
end

-- Событие "данные загружены" (из WebRequest или моков) — наполняет модель.
function PartyService.load(onLoaded)
  DataLoader.loadParty(function(party)
    local partyById = {}
    for _, character in ipairs(party) do
      partyById[character.id] = character
    end
    store:setState({ party = party, partyById = partyById })
    if onLoaded ~= nil then onLoaded() end
  end)
end

-- Намерение "выбрать персонажа" (клик по портрету). Не трогает openCharacterId.
function PartyService.selectCharacter(playerColor, characterId)
  store:setState({ selectedCharacterId = characterId, lastPlayerColor = playerColor })
end

-- Намерение "открыть полную панель для выбранного персонажа".
function PartyService.openCharacterSheet(playerColor)
  local state = store:getState()
  if state.selectedCharacterId == nil then return end
  store:setState({
    openCharacterId = state.selectedCharacterId,
    lastPlayerColor = playerColor,
  })
end

function PartyService.closeCharacterSheet()
  store:setState({ openCharacterId = Store.NULL })
end

-- Реальной системы эффектов способностей пока нет — заглушка, чтобы UI-слой
-- уже сейчас звал сервис, а не решал сам, что значит "использовать способность".
function PartyService.useAbility(abilityId)
  local state = store:getState()
  local character = state.partyById[state.selectedCharacterId]
  if character == nil then return end
  printToAll(string.format("%s использует способность: %s", character.name, abilityId), { 0.8, 0.8, 0.4 })
end

return PartyService
