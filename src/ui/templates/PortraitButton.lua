-- XML-шаблон как Lua-модуль: бандлер TTS Editor резолвит require() только
-- по ?.lua / ?.ttslua, .xml он не видит. Внутри — сырой XML, 1:1.
return [[
<Panel width="120" height="120" color="{{BORDER_COLOR}}">
  <Button id="character_{{CHARACTER_ID}}" width="114" height="114" color="{{BG_COLOR}}" onClick="selectCharacter">
    <VerticalLayout padding="4 4 4 4" spacing="2">
      <Text alignment="UpperCenter" fontSize="40" color="#e6cd85">{{INITIAL}}</Text>
      <Text alignment="LowerCenter" fontSize="14" color="#f0dfae">{{HP}}</Text>
    </VerticalLayout>
  </Button>
</Panel>
]]
