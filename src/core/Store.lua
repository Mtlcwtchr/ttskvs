-- Минимальный реактивный контейнер состояния: setState мержит патч и
-- уведомляет подписчиков. Ничего не знает ни про TTS UI, ни про партию —
-- это общий примитив, на котором строятся сервисы в core/.
--
-- В конструкторе таблицы `{ key = nil }` ключ вообще не создаётся (в Lua
-- нет способа хранить nil в таблице), поэтому pairs() его не увидит и
-- setState({ key = nil }) молча ничего не сотрёт. Store.NULL — sentinel для
-- явного "сбросить поле в nil" в патче.
local Store = {}
Store.__index = Store

Store.NULL = setmetatable({}, { __tostring = function() return "Store.NULL" end })

function Store.new(initialState)
  return setmetatable({ _state = initialState, _listeners = {} }, Store)
end

function Store:getState()
  return self._state
end

function Store:setState(patch)
  for key, value in pairs(patch) do
    self._state[key] = (value == Store.NULL) and nil or value
  end
  for _, listener in ipairs(self._listeners) do
    listener(self._state)
  end
end

function Store:subscribe(listener)
  table.insert(self._listeners, listener)
end

return Store
