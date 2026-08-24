-- AUTO-GENERATED из src/ui/layout/**/*.xml командой `python3 tools/tts_bridge.py sync-xml`.
-- Не редактировать руками — правьте .xml, файл пересобирается.
-- Внутри — та же разметка без XML-комментариев.
local Templates = {}

Templates["Badge"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{BORDER_COLOR}}" padding="1" at="{{AT}}">
  <Box width="fill" height="fill" color="{{COLOR}}">
    <Note height="fill" fontSize="{{FONT_SIZE}}" color="{{TEXT_COLOR}}">{{VALUE}}</Note>
  </Box>
</Box>]]

Templates["Frame"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{BORDER_COLOR}}" padding="{{BORDER}}">{{CONTENT}}</Box>]]

Templates["InputField"] = [[<InputField id="{{ID}}" width="{{WIDTH}}" height="{{HEIGHT}}" font="Arial" fontSize="{{FONT_SIZE}}"
            colors="{{COLORS}}" textColor="{{TEXT_COLOR}}" caretColor="caret"
            padding="2 4 2 4"
            horizontalOverflow="Overflow" verticalOverflow="Overflow"
            onEndEdit="{{ON_END_EDIT}}" onValueChanged="{{ON_VALUE_CHANGED}}"
            characterValidation="{{VALIDATION}}"
            resizeTextForBestFit="true" resizeTextMinSize="8"
            interactable="true" readOnly="false" lineType="{{LINE_TYPE}}" text="{{VALUE}}" />]]

Templates["LabeledField"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" gap="2" align="topleft">
  <Box width="fill" height="{{LABEL_HEIGHT}}">
    <Caption height="fill" fontSize="{{LABEL_FONT_SIZE}}" alignment="MiddleLeft" color="{{LABEL_COLOR}}">{{LABEL}}</Caption>
  </Box>
  <Box width="fill" height="{{FIELD_HEIGHT}}" color="{{FIELD_COLOR}}">{{FIELD}}</Box>
</Col>]]

Templates["Section"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="{{HEADER_GAP}}" align="topleft">
  <Row width="fill" height="{{TITLE_HEIGHT}}" gap="0" align="left">
    <Caption height="fill" width="fill" fontSize="{{TITLE_FONT_SIZE}}" font="{{TITLE_FONT}}" alignment="{{TITLE_ALIGNMENT}}" color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
  </Row>
  <Col width="fill" height="fill" gap="{{CONTENT_GAP}}" align="topleft">{{CONTENT}}</Col>
</Col>]]

Templates["SectionFooter"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="{{HEADER_GAP}}" align="topleft">
  <Col width="fill" height="fill" gap="{{CONTENT_GAP}}" align="topleft">{{CONTENT}}</Col>
  <Box width="fill" height="1" color="divider"/>
  <Row width="fill" height="{{TITLE_HEIGHT}}" gap="0" align="left">
    <Caption height="fill" width="fill" fontSize="{{TITLE_FONT_SIZE}}" font="{{TITLE_FONT}}" alignment="{{TITLE_ALIGNMENT}}" color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
  </Row>
</Col>]]

Templates["SignedValue"] = [[<Text width="{{WIDTH}}" height="{{HEIGHT}}" fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{VALUE}}</Text>]]

Templates["Slot"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="{{GAP}}" align="topleft">{{CONTENT}}</Col>]]

Templates["StatBar"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="5" align="topleft">
  <Row width="fill" height="{{TITLE_HEIGHT}}" gap="6" align="left">
    <Box width="fill" height="fill">
      <Caption height="fill" alignment="MiddleLeft" fontSize="{{TITLE_FONT_SIZE}}" color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
    </Box>
    <Box width="{{VALUE_WIDTH}}" height="fill">{{VALUE}}</Box>
  </Row>
  <Box width="fill" height="{{TRACK_HEIGHT}}" color="{{TRACK_COLOR}}" padding="1">
    <Box width="{{FILL_PERCENT}}" height="fill" at="left" color="{{FILL_COLOR}}"/>
  </Box>
</Col>]]

Templates["TextLine"] = [[<Text width="{{WIDTH}}" height="{{HEIGHT}}" font="{{FONT}}" fontSize="{{FONT_SIZE}}" alignment="{{ALIGNMENT}}"
      color="{{COLOR}}" horizontalOverflow="{{OVERFLOW}}">{{CONTENT}}</Text>]]

Templates["Tile"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="1" align="topleft">
  <Row width="fill" height="{{LABEL_HEIGHT}}" gap="0" align="center">
    <Caption height="fill" width="fill" fontSize="{{LABEL_FONT_SIZE}}" alignment="MiddleCenter" color="{{LABEL_COLOR}}">{{LABEL}}</Caption>
  </Row>
  <Box width="fill" height="fill">{{VALUE}}</Box>
  {{SUB_BLOCK}}
</Col>]]

Templates["AbilityTile"] = [[<Tile label="{{LABEL}}" sub="{{SUB}}" width="{{WIDTH}}" height="{{HEIGHT}}">{{VALUE}}</Tile>]]

Templates["AddCharacterButton"] = [[<Box width="{{SIZE}}" height="{{SIZE}}" color="emptySeatBorder" padding="1">
  <Button id="create_character" width="fill" height="fill" colors="seatStates" textColor="seatText"
          textAlignment="MiddleCenter" fontSize="30" onClick="createCharacter">+</Button>
</Box>]]

Templates["AttackEditRow"] = [[<Row width="fill" height="{{HEIGHT}}" gap="6" align="left">
  <Box width="3fr" height="fill">{{NAME}}</Box>
  <Box width="70" height="fill">{{BONUS}}</Box>
  <Box width="2fr" height="fill">{{DAMAGE}}</Box>
</Row>]]

Templates["AttackRow"] = [[<Text fontSize="13" alignment="MiddleLeft" color="textBody">• {{NAME}}   {{BONUS}}   {{DAMAGE}}</Text>]]

Templates["CharacterSheet"] = [[<Anchor id="character_sheet_root" at="topleft" x="158" y="75" width="1255" height="930" color="brass" padding="2">
  <Box width="fill" height="fill" color="bgDeepest" padding="4">
    <Col width="fill" height="fill" color="sheetBg" padding="14" gap="8" align="topleft">

      <Row width="fill" height="40" gap="12" align="left">
        <Box width="fill" height="fill" color="brass" padding="1">
          <Box width="fill" height="fill" color="bgPanelLight" padding="8 8 0 0">
            <Field name="field_name" fontSize="24" color="goldPale" alignment="MiddleLeft" height="fill"/>
          </Box>
        </Box>
        <Box width="150" height="fill">
          <ViewOnly>
            <SheetButton id="sheet_edit" label="Редактировать" tone="gold" onClick="startWizard"/>
          </ViewOnly>
          <WizardOnly>
            <SheetButton id="sheet_finish" label="Готово" tone="gold" onClick="finishWizard"/>
          </WizardOnly>
        </Box>
        <Box width="96" height="fill">
          <SheetButton id="sheet_close" label="Закрыть" tone="quiet" onClick="closeSheet"/>
        </Box>
        <WizardOnly>
          <Box width="120" height="fill">
            <SheetButton id="sheet_delete" label="Удалить" tone="danger" onClick="deleteCharacter"/>
          </Box>
        </WizardOnly>
      </Row>

      <Row width="fill" height="38" gap="8" align="left">
        <HeaderChip label="РАСА" name="field_race" width="fill"/>
      </Row>

      <Box width="fill" height="1" color="divider"/>

      <Row width="fill" height="fill" gap="14" align="topleft">

        <Row width="320" height="fill" gap="10" align="topleft">
          <Col width="82" height="fill" gap="6" align="topleft">
            <AbilityTile label="СИЛА" name="field_ability_STR"/>
            <AbilityTile label="ЛОВКОСTЬ" name="field_ability_DEX"/>
            <AbilityTile label="TЕЛОСЛОЖ." name="field_ability_CON"/>
            <AbilityTile label="ИНTЕЛЛЕКT" name="field_ability_INT"/>
            <AbilityTile label="МУДРОСTЬ" name="field_ability_WIS"/>
            <AbilityTile label="ХАРИЗМА" name="field_ability_CHA"/>
          </Col>

          <Col width="fill" height="fill" gap="10" align="topleft">
            <Section title="НАВЫКИ" titleAt="bottom" titleHeight="16" titleFontSize="8" height="fill">
              <Col width="fill" height="fill" gap="1" align="topleft">
                <SkillList/>
              </Col>
            </Section>
          </Col>
        </Row>

        <Col width="340" height="fill" gap="12" align="topleft">
          <Box width="fill" height="fill" color="borderDim" padding="1">
            <Col width="fill" height="fill" color="bgPanel" padding="8" gap="6" align="topleft">

              <Box width="fill" height="fill" color="brassDim" padding="1">
                <Box width="fill" height="fill" color="bgTileDeep">
                  <PortraitLetter fontSize="44"/>
                </Box>
              </Box>

              <Row width="fill" height="60" gap="5" align="topleft">
                <EquipSlot slot="armor" label="СНАРЯЖ."/>
                <EquipSlot slot="accessory1" label="АКСЕСС. 1"/>
                <EquipSlot slot="accessory2" label="АКСЕСС. 2"/>
                <EquipSlot slot="hand_r" label="ПРАВАЯ"/>
                <EquipSlot slot="hand_l" label="ЛЕВАЯ"/>
              </Row>

              <Row width="fill" height="72" gap="10" align="bottom">
                <CombatTile label="БЛИЖНИЙ" name="field_melee_bonus" signed="true" width="56" height="56"/>
                <CombatTile label="БРОНЯ" name="field_armor_class" width="66" height="72" tone="gold"/>
                <CombatTile label="ДАЛЬНИЙ" name="field_ranged_bonus" signed="true" width="56" height="56"/>
              </Row>
            </Col>
          </Box>

          <Col width="fill" height="auto" gap="6" align="topleft">
            <Resource title="ХИTЫ" current="field_hp_current" max="field_hp_max" height="46"/>
            <Resource title="ВЫНОСЛИВОСTЬ" current="field_stamina_current" max="field_stamina_max" height="46"
                      fillColor="staminaGold"/>
            <Resource title="МАНА" current="field_mana_current" max="field_mana_max" height="46"
                      fillColor="manaBlue"/>
            <ViewOnly>
              <Row width="fill" height="26" gap="8" align="left">
                <HeaderChip label="ВРЕМ. ХИTЫ" name="field_hp_temp" width="1fr" fontSize="12"/>
                <HeaderChip label="КОСTИ ХИTОВ" name="field_hit_dice" width="1fr" fontSize="12"/>
                <HeaderChip label="СКОРОСTЬ" name="field_speed" width="1fr" fontSize="12"/>
              </Row>
            </ViewOnly>
            <WizardOnly>
              <Row width="fill" height="44" gap="6" align="left">
                <LabeledField label="Врем. хиты" name="field_hp_temp"/>
                <LabeledField label="Кости хитов" name="field_hit_dice"/>
                <LabeledField label="Скорость" name="field_speed"/>
              </Row>
            </WizardOnly>
          </Col>
        </Col>

        <Col width="fill" height="fill" gap="10" align="topleft">
          <Box width="fill" height="auto" color="borderDim" padding="1">
            <Section title="ИНВЕНTАРЬ" titleHeight="16" titleFontSize="8" color="bgPanel">
              <Col width="fill" height="auto" gap="5" align="topleft">
                <InventoryList/>
              </Col>
            </Section>
          </Box>

          <Box width="fill" height="fill" color="borderDim" padding="1">
            <Section title="СПОСОБНОСTИ И ОБЕTЫ" titleHeight="18" titleFontSize="8" color="bgPanel">
              <Scroll width="fill" height="fill" gap="7">
                <Features/>
              </Scroll>
            </Section>
          </Box>

          <Box width="fill" height="fill" color="borderDim" padding="1">
            <Section title="ЗАМЕTКИ" titleHeight="16" titleFontSize="8" color="bgPanel">
              <Scroll width="fill" height="fill" gap="6">
                <CustomGroups group="notes"/>
              </Scroll>
            </Section>
          </Box>
        </Col>

      </Row>
    </Col>
  </Box>
</Anchor>]]

Templates["ClassLine"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{RACE}} • {{CLASS}} {{LEVEL}}</Text>]]

Templates["CombatSummary"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="textMuted">Временные хиты: {{TEMP}}   •   Кости хитов: {{DICE}}</Text>]]

Templates["CombatTile"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{BORDER_COLOR}}" padding="1">
  <Tile label="{{LABEL}}" color="{{COLOR}}" padding="2 2 3 3">{{VALUE}}</Tile>
</Box>]]

Templates["CustomGroupEditRow"] = [[<Row width="fill" height="{{HEIGHT}}" gap="4" padding="4 4 2 2" align="topleft">
  <Col width="fill" height="fill" gap="6" align="topleft">
    <Box width="fill" height="16">{{TITLE_FIELD}}</Box>
    <Box width="fill" height="fill">{{DESC_FIELD}}</Box>
  </Col>
  <Box width="22" height="22" at="right">{{DELETE_BUTTON}}</Box>
</Row>]]

Templates["CustomGroupRow"] = [[<Col width="fill" height="auto" gap="2" padding="4 4 2 2" align="topleft">
  <Box width="fill" height="14">
    <Caption height="fill" alignment="MiddleLeft" fontSize="9" color="textMuted">{{TITLE}}</Caption>
  </Box>
  <Box width="fill" height="{{TEXT_HEIGHT}}">
    <Note height="fill" fontSize="12" alignment="UpperLeft" color="textBody" wrap="true">{{DESCRIPTION}}</Note>
  </Box>
  <Box width="fill" height="1" color="divider"/>
</Col>]]

Templates["EquipSlot"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{BORDER_COLOR}}" padding="1">
  <Col width="fill" height="fill" color="{{COLOR}}" padding="3" gap="0" align="topleft">
    <Box width="fill" height="10">
      <Caption height="fill" fontSize="8" alignment="MiddleCenter" color="slotLabel">{{LABEL}}</Caption>
    </Box>
    <Box width="fill" height="fill">{{VALUE}}</Box>
  </Col>
</Box>]]

Templates["Experience"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{CURRENT}} / {{NEXT}}</Text>]]

Templates["FeatureEditRow"] = [[<Col width="fill" height="{{HEIGHT}}" gap="3" align="topleft">
  <Row width="fill" height="fill" gap="6" align="left">
    <Box width="2fr" height="fill">{{NAME}}</Box>
    <Box width="110" height="fill">{{TYPE}}</Box>
  </Row>
  <Box width="fill" height="fill">{{DESC}}</Box>
</Col>]]

Templates["FeatureRow"] = [[<Row width="fill" height="{{HEIGHT}}" gap="9" align="topleft">
  <Box width="30" height="30" color="brass" padding="1">
    <Box width="fill" height="fill" color="bgTile">
      <Caption height="fill" fontSize="8" color="slotLabel">{{ICON}}</Caption>
    </Box>
  </Box>
  <Col width="fill" height="fill" gap="1" align="topleft">
    <Box width="fill" height="16">
      <Note height="fill" fontSize="14" alignment="MiddleLeft" color="textName">{{NAME}}</Note>
    </Box>
    <Box width="fill" height="fill">
      <Note height="fill" fontSize="11" alignment="UpperLeft" color="textBody" wrap="true">{{DESC}}</Note>
    </Box>
  </Col>
</Row>]]

Templates["HeaderChip"] = [[<Col width="{{WIDTH}}" height="fill" color="{{COLOR}}" padding="6 6 3 3" gap="0" align="topleft">
  <Box width="fill" height="11">
    <Caption height="fill" fontSize="8" alignment="MiddleLeft" color="labelGold">{{LABEL}}</Caption>
  </Box>
  <Box width="fill" height="fill">{{VALUE}}</Box>
</Col>]]

Templates["InventoryCell"] = [[<Box width="{{WIDTH}}" height="{{HEIGHT}}" color="{{BORDER_COLOR}}" padding="1">
  <Col width="fill" height="fill" color="{{COLOR}}" padding="3" gap="1" align="topleft">{{VALUE}}</Col>
</Box>]]

Templates["InventoryGridRow"] = [[<Row width="fill" height="{{HEIGHT}}" gap="{{GAP}}" align="topleft">{{CELLS}}</Row>]]

Templates["InventoryRow"] = [[<Text fontSize="13" alignment="MiddleLeft" color="textBody">• {{NAME}} ×{{QTY}}</Text>]]

Templates["MainUI"] = [[<Box width="fill" height="fill">
  <Defaults>
    <Text color="textBody" font="Arial" horizontalOverflow="Overflow" verticalOverflow="Overflow"/>
    <Button colors="buttonStates" font="Arial" textColor="buttonText" textAlignment="MiddleCenter"
            transition="ColorTint"/>
    <InputField colors="inputStates" font="Arial" textColor="inputText" caretColor="caret"/>
  </Defaults>

  <Anchor at="topleft" x="22" y="130" width="100" height="auto">
    <PartyRail/>
  </Anchor>

  <CharacterSheet/>
</Box>]]

Templates["PartyRail"] = [[<Col width="fill" height="auto" color="{{COLOR}}" padding="10" gap="12" align="top">
  {{PORTRAITS}}
  <AddCharacterButton size="{{SEAT_SIZE}}"/>
</Col>]]

Templates["PortraitButton"] = [[<Col width="{{SIZE}}" height="auto" gap="0" align="top">
  <Box width="{{SIZE}}" height="{{SIZE}}" color="{{BORDER_COLOR}}" padding="{{BORDER}}">{{BUTTON}}</Box>
  <Box width="{{SIZE}}" height="18" color="{{HP_BORDER_COLOR}}" padding="1">
    <Box width="fill" height="fill" color="bgWindow">
      <Note height="fill" fontSize="11" color="{{HP_COLOR}}">{{HP}}</Note>
    </Box>
  </Box>
</Col>]]

Templates["PortraitLetter"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleCenter" color="{{COLOR}}">{{LETTER}}</Text>]]

Templates["Resource"] = [[<StatBar title="{{TITLE}}" width="{{WIDTH}}" height="{{HEIGHT}}" ratio="{{RATIO}}" fillColor="{{FILL_COLOR}}" trackColor="{{TRACK_COLOR}}">{{VALUE}}</StatBar>]]

Templates["ResourceEditRow"] = [[<Row width="fill" height="fill" gap="4" align="center">
  <Box width="fill" height="{{FIELD_HEIGHT}}">{{CURRENT}}</Box>
  <Box width="fill" height="{{FIELD_HEIGHT}}">{{MAX}}</Box>
</Row>]]

Templates["SaveRow"] = [[<Row width="fill" height="fill" gap="4" align="left">
  <Box width="9" height="9" color="{{DOT_BORDER}}" padding="1" at="center">
    <Button id="{{DOT_ID}}" width="fill" height="fill" colors="{{DOT_COLORS}}" onClick="toggleSave"/>
  </Box>
  <Note height="fill" fontSize="{{FONT_SIZE}}" alignment="MiddleLeft" color="{{COLOR}}">{{BONUS}} {{LABEL}}</Note>
</Row>]]

Templates["SheetButton"] = [[<Button id="{{ID}}" width="{{WIDTH}}" height="{{HEIGHT}}" colors="{{COLORS}}"
        textColor="{{TEXT_COLOR}}" textAlignment="MiddleCenter" fontSize="{{FONT_SIZE}}"
        onClick="{{ON_CLICK}}">{{LABEL}}</Button>]]

Templates["SkillRow"] = [[<Row width="fill" height="{{HEIGHT}}" gap="6" align="left">
  <Box width="9" height="9" color="{{DOT_BORDER}}" padding="1" at="center">
    <Button id="{{DOT_ID}}" width="fill" height="fill" colors="{{DOT_COLORS}}" onClick="toggleSkill"/>
  </Box>
  <Box width="26" height="fill">
    <Note height="fill" fontSize="13" alignment="MiddleRight" color="{{BONUS_COLOR}}">{{BONUS}}</Note>
  </Box>
  <Box width="fill" height="fill">
    <Note height="fill" fontSize="12" alignment="MiddleLeft" color="{{NAME_COLOR}}">{{NAME}}</Note>
  </Box>
  <Box width="30" height="fill">
    <Note height="fill" fontSize="10" alignment="MiddleRight" color="{{ABILITY_COLOR}}">{{ABILITY}}</Note>
  </Box>
</Row>]]

Templates["WeightLine"] = [[<Text fontSize="11" alignment="MiddleLeft" color="textMuted2">Вес: {{CURRENT}} / {{MAX}}</Text>]]

return Templates
