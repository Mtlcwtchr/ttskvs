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

Templates["InputField"] = [[<InputField id="{{ID}}" width="{{WIDTH}}" height="{{HEIGHT}}" fontSize="{{FONT_SIZE}}"
            colors="{{COLORS}}" textColor="{{TEXT_COLOR}}" caretColor="caret"
            onEndEdit="{{ON_END_EDIT}}" characterValidation="{{VALIDATION}}"
            interactable="true" readOnly="false" lineType="{{LINE_TYPE}}" text="{{VALUE}}" />]]

Templates["LabeledField"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" gap="2" align="topleft">
  <Box width="fill" height="{{LABEL_HEIGHT}}">
    <Caption height="fill" fontSize="{{LABEL_FONT_SIZE}}" alignment="MiddleLeft" color="{{LABEL_COLOR}}">{{LABEL}}</Caption>
  </Box>
  <Box width="fill" height="{{FIELD_HEIGHT}}" color="{{FIELD_COLOR}}">{{FIELD}}</Box>
</Col>]]

Templates["Section"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="{{HEADER_GAP}}" align="topleft">
  <Box width="fill" height="{{TITLE_HEIGHT}}">
    <Caption height="fill" fontSize="{{TITLE_FONT_SIZE}}" alignment="{{TITLE_ALIGNMENT}}" color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
  </Box>
  <Col width="fill" height="fill" gap="{{CONTENT_GAP}}" align="topleft">{{CONTENT}}</Col>
</Col>]]

Templates["SectionFooter"] = [[<Col width="{{WIDTH}}" height="{{HEIGHT}}" color="{{COLOR}}" padding="{{PADDING}}" gap="{{HEADER_GAP}}" align="topleft">
  <Col width="fill" height="fill" gap="{{CONTENT_GAP}}" align="topleft">{{CONTENT}}</Col>
  <Box width="fill" height="1" color="divider"/>
  <Box width="fill" height="{{TITLE_HEIGHT}}">
    <Caption height="fill" fontSize="{{TITLE_FONT_SIZE}}" alignment="{{TITLE_ALIGNMENT}}" color="{{TITLE_COLOR}}">{{TITLE}}</Caption>
  </Box>
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
  <Box width="fill" height="{{LABEL_HEIGHT}}">
    <Caption height="fill" fontSize="{{LABEL_FONT_SIZE}}" alignment="MiddleCenter" color="{{LABEL_COLOR}}">{{LABEL}}</Caption>
  </Box>
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

Templates["CharacterSheet"] = [[<Anchor id="character_sheet_root" at="topleft" x="126" y="120" width="1004" height="620" color="brass" padding="2">
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

      <Row width="fill" height="34" gap="8" align="left">
        <HeaderChip label="РАСА" name="field_race" width="2fr"/>
        <HeaderChip label="КЛАСС" name="field_class" width="2fr"/>
        <HeaderChip label="УРОВЕНЬ" name="field_level" width="1fr"/>
        <HeaderChip label="ВОЗРАСТ" name="field_age" width="1fr"/>
        <HeaderChip label="МИРОВОЗЗРЕНИЕ" name="field_alignment" width="2fr"/>
        <HeaderChip label="ИГРОК" name="field_player_name" width="2fr"/>
      </Row>

      <Box width="fill" height="1" color="divider"/>

      <Row width="fill" height="fill" gap="14" align="topleft">

        <Row width="304" height="fill" gap="10" align="topleft">
          <Col width="82" height="fill" gap="6" align="topleft">
            <AbilityTile label="СИЛА" name="field_ability_STR"/>
            <AbilityTile label="ЛОВКОСТЬ" name="field_ability_DEX"/>
            <AbilityTile label="ТЕЛОСЛОЖ." name="field_ability_CON"/>
            <AbilityTile label="ИНТЕЛЛЕКТ" name="field_ability_INT"/>
            <AbilityTile label="МУДРОСТЬ" name="field_ability_WIS"/>
            <AbilityTile label="ХАРИЗМА" name="field_ability_CHA"/>
          </Col>

          <Col width="fill" height="fill" gap="10" align="topleft">
            <Section title="НАВЫКИ" titleAt="bottom" height="fill">
              <Col width="fill" height="fill" gap="1" align="topleft">
                <SkillList/>
              </Col>
            </Section>
            <WizardOnly>
              <Col width="fill" height="98" gap="6" align="topleft">
                <LabeledField label="Спасброски (CSV)" name="field_saves_csv"/>
                <LabeledField label="Владение навыками (CSV)" name="field_skills_csv"/>
              </Col>
            </WizardOnly>
          </Col>
        </Row>

        <Col width="250" height="fill" gap="12" align="topleft">
          <Box width="fill" height="fill" color="borderDim" padding="1">
            <Col width="fill" height="fill" color="bgPanel" padding="8" gap="6" align="topleft">

              <Row width="fill" height="fill" gap="6" align="topleft">
                <Col width="44" height="fill" gap="5" align="topleft">
                  <EquipSlot slot="helm" label="ШЛЕМ"/>
                  <EquipSlot slot="cloak" label="ПЛАЩ"/>
                  <EquipSlot slot="mail" label="ДОСПЕХ"/>
                  <EquipSlot slot="glove" label="ПЕРЧ."/>
                  <EquipSlot slot="boot" label="САПОГИ"/>
                </Col>

                <Box width="fill" height="fill" color="brassDim" padding="1">
                  <Box width="fill" height="fill" color="bgTileDeep">
                    <PortraitLetter fontSize="44"/>
                  </Box>
                </Box>

                <Col width="44" height="fill" gap="5" align="topleft">
                  <EquipSlot slot="amulet" label="АМУЛЕТ"/>
                  <EquipSlot slot="ring1" label="КОЛЬЦО"/>
                  <EquipSlot slot="ring2" label="КОЛЬЦО"/>
                  <EquipSlot slot="belt" label="ПОЯС"/>
                  <EquipSlot slot="charm" label="ОБЕРЕГ"/>
                </Col>
              </Row>

              <Row width="fill" height="72" gap="10" align="bottom">
                <CombatTile label="БЛИЖНИЙ" name="field_melee_bonus" signed="true" width="56" height="56"/>
                <CombatTile label="БРОНЯ" name="field_armor_class" width="66" height="72" tone="gold"/>
                <CombatTile label="ДАЛЬНИЙ" name="field_ranged_bonus" signed="true" width="56" height="56"/>
              </Row>
            </Col>
          </Box>

          <Col width="fill" height="auto" gap="6" align="topleft">
            <Resource title="ХИТЫ" current="field_hp_current" max="field_hp_max" height="46"/>
            <Resource title="ВЫНОСЛИВОСТЬ" current="field_stamina_current" max="field_stamina_max" height="46"
                      fillColor="staminaGold"/>
            <Resource title="МАНА" current="field_mana_current" max="field_mana_max" height="46"
                      fillColor="manaBlue"/>
            <ViewOnly>
              <Row width="fill" height="26" gap="8" align="left">
                <HeaderChip label="ВРЕМ. ХИТЫ" name="field_hp_temp" width="1fr" fontSize="12"/>
                <HeaderChip label="КОСТИ ХИТОВ" name="field_hit_dice" width="1fr" fontSize="12"/>
                <HeaderChip label="СКОРОСТЬ" name="field_speed" width="1fr" fontSize="12"/>
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
            <Col width="fill" height="auto" color="bgPanel" padding="8" gap="5" align="topleft">
              <InventoryList/>
            </Col>
          </Box>

          <Box width="fill" height="fill" color="borderDim" padding="1">
            <Section title="СПОСОБНОСТИ И ОБЕТЫ" color="bgPanel">
              <Scroll width="fill" height="fill" gap="7">
                <Features/>
              </Scroll>
            </Section>
          </Box>

          <Row width="fill" height="fill" gap="10" align="topleft">
            <Box width="fill" height="fill" color="borderDim" padding="1">
              <Section title="ВЛАДЕНИЯ И ЗНАНИЯ" color="bgPanel">
                <Scroll width="fill" height="fill" gap="6">
                  <CustomGroups group="lore"/>
                </Scroll>
              </Section>
            </Box>
            <Box width="fill" height="fill" color="borderDim" padding="1">
              <Section title="ЗАМЕТКИ ЗА СТОЛОМ" color="bgPanel">
                <Scroll width="fill" height="fill" gap="6">
                  <CustomGroups group="notes"/>
                </Scroll>
              </Section>
            </Box>
          </Row>
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

Templates["CustomGroupEditRow"] = [[<Col width="fill" height="{{HEIGHT}}" gap="1" align="topleft">
  <Box width="fill" height="12">{{TITLE_FIELD}}</Box>
  <Box width="fill" height="fill">{{DESC_FIELD}}</Box>
</Col>]]

Templates["CustomGroupRow"] = [[<Col width="fill" height="auto" gap="1" align="topleft">
  <Box width="fill" height="13">
    <Caption height="fill" alignment="MiddleLeft" fontSize="9" color="textMuted">{{TITLE}}</Caption>
  </Box>
  <Box width="fill" height="{{TEXT_HEIGHT}}">
    <Note height="fill" fontSize="12" alignment="UpperLeft" color="textBody" wrap="true">{{DESCRIPTION}}</Note>
  </Box>
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
    <Text color="textBody" font="CormorantGaramond" horizontalOverflow="Overflow" verticalOverflow="Truncate"
          resizeTextForBestFit="false"/>
    <Button colors="buttonStates" font="CormorantGaramond" textColor="buttonText" textAlignment="MiddleCenter"
            transition="ColorTint"/>
    <InputField colors="inputStates" font="CormorantGaramond" textColor="inputText" caretColor="caret"/>
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
  <Box width="{{SIZE}}" height="{{SIZE}}" color="{{BORDER_COLOR}}" padding="{{BORDER}}">
    <Button id="{{ID}}" width="fill" height="fill" colors="{{COLORS}}" textColor="{{INITIAL_COLOR}}"
            textAlignment="MiddleCenter" fontSize="{{INITIAL_FONT_SIZE}}" onClick="{{ON_CLICK}}">{{INITIAL}}</Button>
  </Box>
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

Templates["SaveRow"] = [[<Text fontSize="{{FONT_SIZE}}" alignment="MiddleLeft" color="{{COLOR}}">{{MARK}} {{BONUS}} {{LABEL}}</Text>]]

Templates["SheetButton"] = [[<Button id="{{ID}}" width="{{WIDTH}}" height="{{HEIGHT}}" colors="{{COLORS}}"
        textColor="{{TEXT_COLOR}}" textAlignment="MiddleCenter" fontSize="{{FONT_SIZE}}"
        onClick="{{ON_CLICK}}">{{LABEL}}</Button>]]

Templates["SkillRow"] = [[<Row width="fill" height="{{HEIGHT}}" gap="6" align="left">
  <Box width="9" height="9" color="{{DOT_BORDER}}" padding="1" at="center">
    <Box width="fill" height="fill" color="{{DOT_COLOR}}"/>
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
