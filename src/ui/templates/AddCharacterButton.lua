-- XML-шаблон как Lua-модуль: бандлер TTS Editor резолвит require() только
-- по ?.lua / ?.ttslua, .xml он не видит. Внутри — сырой XML, 1:1.
return [[
<Panel width="120" height="120" color="#b08a2e">
  <Button id="create_character" width="114" height="114" color="rgba(0.141, 0.141, 0.110, 0.8)" onClick="createCharacter">
    <Text alignment="MiddleCenter" fontSize="44" color="#e6cd85">+</Text>
  </Button>
</Panel>
]]
