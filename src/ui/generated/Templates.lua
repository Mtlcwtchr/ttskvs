-- AUTO-GENERATED из src/ui/layout/**/*.xml командой `python3 tools/tts_bridge.py sync-xml`.
-- Не редактировать руками — правьте .xml, файл пересобирается.
-- Внутри — та же разметка без XML-комментариев.
local Templates = {}

Templates["Anchor"] = [[<Panel rectAlignment="{{ALIGNMENT}}" offsetXY="{{OFFSET}}" width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">{{CONTENT}}</Panel>]]

Templates["Box"] = [[<Panel width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">{{CONTENT}}</Panel>]]

Templates["Column"] = [[<Panel width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <VerticalLayout padding="{{PADDING}}" spacing="{{SPACING}}" childAlignment="{{CHILD_ALIGNMENT}}">{{CONTENT}}</VerticalLayout>
</Panel>]]

Templates["ColumnFixed"] = [[<Panel width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <VerticalLayout padding="{{PADDING}}" spacing="{{SPACING}}" childAlignment="{{CHILD_ALIGNMENT}}" childControlWidth="false" childControlHeight="false" childForceExpandWidth="false" childForceExpandHeight="false">{{CONTENT}}</VerticalLayout>
</Panel>]]

Templates["Frame"] = [[<Panel width="{{WIDTH}}" height="{{HEIGHT}}" color="{{BORDER_COLOR}}">{{CONTENT}}</Panel>]]

Templates["InputField"] = [[<InputField id="{{ID}}" width="{{WIDTH}}" height="{{HEIGHT}}" onEndEdit="{{ON_END_EDIT}}" characterValidation="{{VALIDATION}}" interactable="true" readOnly="false" lineType="{{LINE_TYPE}}" text="{{VALUE}}" />]]

Templates["Line"] = [[<HorizontalLayout padding="{{PADDING}}" spacing="{{SPACING}}" childAlignment="{{CHILD_ALIGNMENT}}">{{CONTENT}}</HorizontalLayout>]]

Templates["LineFixed"] = [[<HorizontalLayout padding="{{PADDING}}" spacing="{{SPACING}}" childAlignment="{{CHILD_ALIGNMENT}}" childControlWidth="false" childControlHeight="false" childForceExpandWidth="false" childForceExpandHeight="false">{{CONTENT}}</HorizontalLayout>]]

Templates["Section"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <Column fit="fixed" width="{{WIDTH}}" height="{{HEIGHT}}" spacing="{{HEADER_SPACING}}" childAlignment="UpperLeft">
    <Box width="{{WIDTH}}" height="{{TITLE_HEIGHT}}" color="{{COLOR}}">
      <Caption fontSize="{{TITLE_FONT_SIZE}}" alignment="{{TITLE_ALIGNMENT}}" color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
    </Box>
    <Box width="{{WIDTH}}" height="{{CONTENT_HEIGHT}}" color="{{COLOR}}">
      <Stack fit="fixed" padding="{{CONTENT_PADDING}}" spacing="{{CONTENT_SPACING}}" childAlignment="UpperLeft">
        {{CONTENT}}
      </Stack>
    </Box>
  </Column>
</Box>]]

Templates["SignedValue"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{VALUE}}</Text>]]

Templates["Slot"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <Stack padding="6 6 2 2" spacing="0">{{CONTENT}}</Stack>
</Box>]]

Templates["Stack"] = [[<VerticalLayout padding="{{PADDING}}" spacing="{{SPACING}}" childAlignment="{{CHILD_ALIGNMENT}}">{{CONTENT}}</VerticalLayout>]]

Templates["StackFixed"] = [[<VerticalLayout padding="{{PADDING}}" spacing="{{SPACING}}" childAlignment="{{CHILD_ALIGNMENT}}" childControlWidth="false" childControlHeight="false" childForceExpandWidth="false" childForceExpandHeight="false">{{CONTENT}}</VerticalLayout>]]

Templates["StatBar"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <Stack padding="8 8 8 8" spacing="6">
    <Caption color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
    {{VALUE}}
    <Panel height="12" color="{{TRACK_COLOR}}">
      <Panel rectAlignment="MiddleLeft" width="{{FILL_WIDTH}}" height="12" color="{{FILL_COLOR}}" />
    </Panel>
  </Stack>
</Box>]]

Templates["TextLine"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="{{ALIGNMENT}}" color="{{COLOR}}">{{CONTENT}}</Text>]]

Templates["Tile"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <Stack padding="4 4 4 4" spacing="0">
    <Caption fontSize="8" alignment="MiddleCenter" color="{{LABEL_COLOR}}">{{LABEL}}</Caption>
    {{VALUE}}
    {{SUB_BLOCK}}
  </Stack>
</Box>]]

Templates["AbilityTile"] = [[<Tile label="{{LABEL}}" sub="{{SUB}}" width="{{WIDTH}}" height="{{HEIGHT}}">{{VALUE}}</Tile>]]

Templates["AddCharacterButton"] = [[<Frame width="120" height="120" borderColor="frameAccent">
  <Button id="create_character" width="114" height="114" color="buttonBg" fontSize="44" onClick="createCharacter">+</Button>
</Frame>]]

Templates["AttackEditRow"] = [[<Line fit="fixed" spacing="6">{{NAME}}{{BONUS}}{{DAMAGE}}</Line>]]

Templates["AttackRow"] = [[<Text fontSize="13" alignment="MiddleLeft" color="textBody">• {{NAME}}   {{BONUS}}   {{DAMAGE}}</Text>]]

Templates["CharacterSheet"] = [[<Sheet width="1320" height="900" color="sheetBg">
  <Stack padding="16 16 16 16" spacing="10">

    <Box width="1288" height="60" color="bgPanel">
      <Line fit="fixed" padding="6 8 6 8" spacing="10" childAlignment="MiddleLeft">
        <Slot width="46" height="46" color="bgTile">
          <PortraitLetter/>
        </Slot>

        <Column width="860" height="46" spacing="2" childAlignment="UpperLeft">
          <Field name="field_name" fontSize="24" color="goldBright" width="850" height="26"/>
          <Line fit="fixed" spacing="6" childAlignment="MiddleLeft">
            <Caption>RACE</Caption>
            <Field name="field_race" width="160" height="18"/>
            <Caption>AGE</Caption>
            <Field name="field_age" width="70" height="18"/>
          </Line>
        </Column>

        <Column fit="fixed" width="132" height="46" spacing="2">
          <ViewOnly>
            <SheetButton id="sheet_edit" label="Edit" onClick="startWizard"/>
          </ViewOnly>
          <WizardOnly>
            <SheetButton id="sheet_finish" label="Done" color="gold" onClick="finishWizard"/>
          </WizardOnly>
          <SheetButton id="sheet_close" label="Close" color="gold" onClick="closeSheet"/>
        </Column>

        <WizardOnly>
          <Column fit="fixed" width="120" height="46" spacing="2">
            <SheetButton id="sheet_delete" label="Delete" color="dangerRed" onClick="deleteCharacter"/>
          </Column>
        </WizardOnly>
      </Line>
    </Box>

    <Line fit="fixed" spacing="10" childAlignment="UpperLeft">

      <Column fit="fixed" width="290" height="760" spacing="8">
        <Section title="ATTRIBUTES" width="290" height="300" spacing="3">
          <Box width="278" height="84" color="transparent">
            <Line fit="fixed" spacing="6">
              <AbilityTile label="Strength" name="field_ability_STR" width="136" height="84"/>
              <AbilityTile label="Dexterity" name="field_ability_DEX" width="136" height="84"/>
            </Line>
          </Box>
          <Box width="278" height="84" color="transparent">
            <Line fit="fixed" spacing="6">
              <AbilityTile label="Constitution" name="field_ability_CON" width="136" height="84"/>
              <AbilityTile label="Intelligence" name="field_ability_INT" width="136" height="84"/>
            </Line>
          </Box>
          <Box width="278" height="84" color="transparent">
            <Line fit="fixed" spacing="6">
              <AbilityTile label="Wisdom" name="field_ability_WIS" width="136" height="84"/>
              <AbilityTile label="Charisma" name="field_ability_CHA" width="136" height="84"/>
            </Line>
          </Box>
          <WizardOnly>
            <LabeledField label="Saves (CSV)" name="field_saves_csv" width="250"/>
          </WizardOnly>
        </Section>

        <Section title="SKILLS" width="290" height="452" spacing="4">
          <SkillList/>
          <WizardOnly>
            <LabeledField label="Proficiencies (CSV)" name="field_skills_csv" width="250"/>
          </WizardOnly>
        </Section>
      </Column>

      <Column fit="fixed" width="478" height="760" spacing="8">
        <Section title="CHARACTER &amp; EQUIPMENT" width="478" height="540" spacing="4">
          <Box width="466" height="334" color="transparent">
            <Line fit="fixed" spacing="8" childAlignment="UpperCenter">
              <Column fit="fixed" width="112" height="334" spacing="6">
                <EquipSlot slot="helm" label="Helm" width="112" height="58"/>
                <EquipSlot slot="cloak" label="Cloak" width="112" height="58"/>
                <EquipSlot slot="mail" label="Armor" width="112" height="58"/>
                <EquipSlot slot="glove" label="Gloves" width="112" height="58"/>
                <EquipSlot slot="boot" label="Boots" width="112" height="58"/>
              </Column>
              <Box width="214" height="334" color="bgPanelLight">
                <Stack padding="8 8 8 8" spacing="6">
                  <Caption>CHARACTER PREVIEW</Caption>
                  <Slot width="198" height="288" color="bgDeepest">
                    <PortraitLetter/>
                  </Slot>
                </Stack>
              </Box>
              <Column fit="fixed" width="112" height="334" spacing="6">
                <EquipSlot slot="amulet" label="Amulet" width="112" height="58"/>
                <EquipSlot slot="ring1" label="Ring I" width="112" height="58"/>
                <EquipSlot slot="ring2" label="Ring II" width="112" height="58"/>
                <EquipSlot slot="belt" label="Belt" width="112" height="58"/>
                <EquipSlot slot="charm" label="Charm" width="112" height="58"/>
              </Column>
            </Line>
          </Box>

          <Box width="466" height="24" color="transparent"/>

          <Box width="466" height="84" color="transparent">
            <Line fit="fixed" spacing="8" childAlignment="UpperCenter">
              <CombatTile label="ARMOR CLASS" name="field_armor_class" width="148" height="84"/>
              <CombatTile label="MELEE ATTACK" name="field_melee_bonus" signed="true" width="148" height="84"/>
              <CombatTile label="RANGED ATTACK" name="field_ranged_bonus" signed="true" width="148" height="84"/>
            </Line>
          </Box>
        </Section>

        <Section title="RESOURCES" width="478" height="212" spacing="4">
          <Box width="466" height="132" color="transparent">
            <Line fit="fixed" spacing="6" childAlignment="UpperCenter">
              <Resource title="HP" current="field_hp_current" max="field_hp_max" width="152" height="132"/>
              <Resource title="STAMINA" current="field_stamina_current" max="field_stamina_max" width="152" height="132"
                        fillColor="positiveGreen" trackColor="bgPanelLight"/>
              <Resource title="MANA" current="field_mana_current" max="field_mana_max" width="152" height="132"
                        fillColor="gold" trackColor="bgPanelLight"/>
            </Line>
          </Box>
          <WizardOnly>
            <Line fit="fixed" spacing="8">
              <LabeledField label="Временные хиты" name="field_hp_temp" width="145"/>
              <LabeledField label="Кости хитов" name="field_hit_dice" width="145"/>
              <LabeledField label="Скорость" name="field_speed" width="145"/>
            </Line>
          </WizardOnly>
        </Section>
      </Column>

      <Column fit="fixed" width="500" height="760" spacing="8">
        <Section title="INVENTORY" width="500" height="272" spacing="4">
          <InventoryList/>
        </Section>

        <Section title="ABILITIES" width="500" height="230" spacing="4">
          <VerticalScrollView width="488" height="198">
            <Stack fit="fixed" spacing="4" childAlignment="UpperLeft">
              <Features/>
            </Stack>
          </VerticalScrollView>
        </Section>

        <Section title="EXTRA NOTES" width="500" height="242" spacing="4">
          <VerticalScrollView width="488" height="210">
            <Stack fit="fixed" spacing="6" childAlignment="UpperLeft">
              <CustomGroups/>
            </Stack>
          </VerticalScrollView>
        </Section>
      </Column>

    </Line>
  </Stack>
</Sheet>]]

Templates["ClassLine"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{RACE}} • {{CLASS}} {{LEVEL}}</Text>]]

Templates["CombatSummary"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="textMuted">Временные хиты: {{TEMP}}   •   Кости хитов: {{DICE}}</Text>]]

Templates["CombatTile"] = [[<Tile label="{{LABEL}}" width="{{WIDTH}}" height="{{HEIGHT}}">{{VALUE}}</Tile>]]

Templates["CustomGroupEditRow"] = [[<Line fit="fixed" spacing="6">
  {{TITLE_FIELD}}
  {{DESC_FIELD}}
</Line>]]

Templates["CustomGroupRow"] = [[<Column fit="fixed" width="460" height="56" spacing="1">
  <Caption alignment="MiddleLeft" color="goldDim">{{TITLE}}</Caption>
  <Text fontSize="12" alignment="UpperLeft" color="textBody">{{DESCRIPTION}}</Text>
</Column>]]

Templates["EquipSlot"] = [[<Slot width="{{WIDTH}}" height="{{HEIGHT}}">
  <Caption fontSize="9" alignment="MiddleLeft" color="textMuted2">{{LABEL}}</Caption>
  {{VALUE}}
</Slot>]]

Templates["Experience"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{CURRENT}} / {{NEXT}}</Text>]]

Templates["FeatureEditRow"] = [[<Stack fit="fixed" spacing="3">
  <Line fit="fixed" spacing="6">{{NAME}}{{TYPE}}</Line>
  {{DESC}}
</Stack>]]

Templates["FeatureRow"] = [[<Stack fit="fixed" spacing="1">
  <Text fontSize="13" alignment="MiddleLeft" color="textCream">• {{NAME}}</Text>
  <Text fontSize="11" alignment="MiddleLeft" color="textMuted">{{DESC}}</Text>
</Stack>]]

Templates["InventoryCell"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="bgDeepest">
  <Stack fit="fixed" padding="4 4 4 4" spacing="2" childAlignment="UpperLeft">
    {{VALUE}}
  </Stack>
</Box>]]

Templates["InventoryEditRow"] = [[<Line fit="fixed" spacing="6">{{NAME}}{{QTY}}</Line>]]

Templates["InventoryRow"] = [[<Text fontSize="13" alignment="MiddleLeft" color="textBody">• {{NAME}} ×{{QTY}}</Text>]]

Templates["MainUI"] = [[<Panel>
  <Anchor alignment="MiddleLeft" offset="90 0" width="140" height="800">
    <PartyRail/>
  </Anchor>
  <CharacterSheet/>
</Panel>]]

Templates["PartyRail"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">
  <Stack fit="fixed" padding="10 10 10 10" spacing="10" childAlignment="UpperCenter">
    {{PORTRAITS}}
    <AddCharacterButton/>
  </Stack>
</Box>]]

Templates["PortraitButton"] = [[<Frame width="120" height="120" borderColor="{{BORDER_COLOR}}">
  <Button id="{{ID}}" width="114" height="114" color="{{BG_COLOR}}" fontSize="14" onClick="{{ON_CLICK}}">
    <PortraitContent initial="{{INITIAL}}" hp="{{HP}}"/>
  </Button>
</Frame>]]

Templates["PortraitContent"] = [[<Stack padding="4 4 4 4" spacing="2">
  <Text alignment="UpperCenter" fontSize="40" color="{{INITIAL_COLOR}}">{{INITIAL}}</Text>
  <Text alignment="LowerCenter" fontSize="14" color="{{HP_COLOR}}">{{HP}}</Text>
</Stack>]]

Templates["PortraitLetter"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{LETTER}}</Text>]]

Templates["Resource"] = [[<StatBar title="{{TITLE}}" width="{{WIDTH}}" height="{{HEIGHT}}" ratio="{{RATIO}}" fillColor="{{FILL_COLOR}}" trackColor="{{TRACK_COLOR}}">{{VALUE}}</StatBar>]]

Templates["SaveRow"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleLeft" color="{{COLOR}}">{{MARK}} {{BONUS}} {{LABEL}}</Text>]]

Templates["Sheet"] = [[<Panel id="character_sheet_root" rectAlignment="MiddleCenter" width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}">{{CONTENT}}</Panel>]]

Templates["SheetButton"] = [[<Button id="{{ID}}" width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" fontSize="14" onClick="{{ON_CLICK}}">{{LABEL}}</Button>]]

Templates["SkillRow"] = [[<Box width="272" height="24" color="transparent">
  <Line fit="fixed" spacing="6" childAlignment="MiddleLeft">
    <Text fontSize="12" alignment="MiddleLeft" color="goldBright" width="34">{{BONUS}}</Text>
    <Text fontSize="12" alignment="MiddleLeft" color="textCream" width="194">{{NAME}}</Text>
    <Text fontSize="11" alignment="MiddleRight" color="textMuted" width="32">{{ABILITY}}</Text>
  </Line>
</Box>]]

Templates["WeightLine"] = [[<Text fontSize="11" alignment="MiddleLeft" color="textMuted2">Вес: {{CURRENT}} / {{MAX}}</Text>]]

return Templates
