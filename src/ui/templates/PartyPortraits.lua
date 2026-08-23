-- XML-шаблон как Lua-модуль: бандлер TTS Editor резолвит require() только
-- по ?.lua / ?.ttslua, .xml он не видит. Внутри — сырой XML, 1:1.
return [[
<Panel width="140" height="800" color="rgba(0.078,0.063,0.039,0.92)">
  <VerticalLayout
    padding="10 10 10 10"
    spacing="10"
    childAlignment="UpperCenter"
    childControlWidth="false"
    childControlHeight="false"
    childForceExpandWidth="false"
    childForceExpandHeight="false">
    {{PORTRAIT_BUTTONS}}
    {{ADD_BUTTON}}
  </VerticalLayout>
</Panel>
]]
