-- XML-шаблон как Lua-модуль: бандлер TTS Editor резолвит require() только
-- по ?.lua / ?.ttslua, .xml он не видит. Внутри — сырой XML, 1:1.
return [[
<Panel>
  <Panel rectAlignment="MiddleLeft" offsetX="90" width="140" height="800">
    {{PARTY_PORTRAITS}}
  </Panel>
  {{CHARACTER_SHEET}}
</Panel>
]]
