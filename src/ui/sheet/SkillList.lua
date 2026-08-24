-- Список навыков (4A, колонка 1): точка владения, бонус, название,
-- характеристика. Бонус считается по данным персонажа — модификатор
-- характеристики плюс бонус мастерства, если навык освоен (proficientSkills в
-- data/characters/*.json), а не берётся из захардкоженного списка.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SkillList = {}

SkillList.defaults = {}

-- Порядок как в 4A: сначала освоенные, дальше остальные. Ключ — тот же, что в
-- proficientSkills у персонажа.
local SKILLS = {
  { key = "perception", name = "Внимание", ability = "WIS" },
  { key = "survival", name = "Выживание", ability = "WIS" },
  { key = "insight", name = "Проницат.", ability = "WIS" },
  { key = "animal_handling", name = "Животные", ability = "WIS" },
  { key = "medicine", name = "Медицина", ability = "WIS" },
  { key = "intimidation", name = "Запугивание", ability = "CHA" },
  { key = "persuasion", name = "Убеждение", ability = "CHA" },
  { key = "deception", name = "Обман", ability = "CHA" },
  { key = "performance", name = "Выступление", ability = "CHA" },
  { key = "acrobatics", name = "Акробатика", ability = "DEX" },
  { key = "stealth", name = "Скрытность", ability = "DEX" },
  { key = "sleight_of_hand", name = "Ловк. рук", ability = "DEX" },
  { key = "athletics", name = "Атлетика", ability = "STR" },
  { key = "arcana", name = "Магия", ability = "INT" },
  { key = "investigation", name = "Анализ", ability = "INT" },
  { key = "history", name = "История", ability = "INT" },
  { key = "nature", name = "Природа", ability = "INT" },
  { key = "religion", name = "Религия", ability = "INT" },
}

local ABILITY_SHORT = {
  STR = "СИЛ", DEX = "ЛОВ", CON = "TЕЛ", INT = "ИНT", WIS = "МУД", CHA = "ХАР",
}

function SkillList.render()
  local character = Common.character()
  local proficiencyBonus = tonumber(Common.value("field_proficiency_bonus")) or 0
  local rows = {}

  local proficient = {}
  for _, key in ipairs(character.proficientSkills or {}) do
    proficient[tostring(key):lower()] = true
  end

  for _, skill in ipairs(SKILLS) do
    local hasProficiency = proficient[skill.key] == true
    local bonus = Common.modifier(Common.value("field_ability_" .. skill.ability))
      + (hasProficiency and proficiencyBonus or 0)

    table.insert(rows, Component.render(Templates.SkillRow, {
      HEIGHT = 17,
      BONUS = Common.signed(bonus),
      NAME = Component.escape(skill.name),
      ABILITY = ABILITY_SHORT[skill.ability] or skill.ability,
      DOT_COLOR = Component.color(hasProficiency and "goldBright" or "bgWindow"),
      DOT_BORDER = Component.color(hasProficiency and "goldBright" or "brassDim"),
      BONUS_COLOR = Component.color(hasProficiency and "textCream" or "textBody"),
      NAME_COLOR = Component.color(hasProficiency and "textCream" or "textBody"),
      ABILITY_COLOR = Component.color(hasProficiency and "textMuted" or "textFaint"),
    }))
  end
  return Component.join(rows)
end

return SkillList
