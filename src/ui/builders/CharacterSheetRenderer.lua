local Template = require("ui.templates.CharacterSheetUI")

local CharacterSheetRenderer = {}

local function escapeXml(text)
  local s = tostring(text or "")
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  s = s:gsub("\"", "&quot;")
  s = s:gsub("'", "&apos;")
  s = s:gsub("\r\n", " ")
  s = s:gsub("\n", " ")
  return s
end

local function replaceAll(template, replacements)
  local out = template
  for key, value in pairs(replacements) do
    out = out:gsub("{{" .. key .. "}}", value)
  end
  return out
end

local function equipmentName(character, slot)
  for _, item in ipairs(character.equipment or {}) do
    if item.slot == slot then
      return item.name or ""
    end
  end
  return ""
end

local function skillsCsv(character)
  return table.concat(character.proficientSkills or {}, ", ")
end

function CharacterSheetRenderer.render(character)
  local ability = character.abilityScores or {}
  local hp = character.hp or {}
  local firstWeapon = (character.attacks or {})[1] or {}
  local firstAbility = (character.abilities or {})[1] or {}

  return replaceAll(Template, {
    CHARACTER_ID = escapeXml(character.id or ""),
    NAME = escapeXml(character.name or ""),
    RACE = escapeXml(character.race or ""),
    CLASS = escapeXml(character.class or ""),
    LEVEL = escapeXml(tostring(character.level or 1)),
    PLAYER_NAME = escapeXml(character.playerName or ""),
    HP_CURRENT = escapeXml(tostring(hp.current or 0)),
    HP_MAX = escapeXml(tostring(hp.max or 0)),
    SPEED = escapeXml(tostring(character.speed or 0)),
    STR = escapeXml(tostring(ability.STR or 10)),
    DEX = escapeXml(tostring(ability.DEX or 10)),
    CON = escapeXml(tostring(ability.CON or 10)),
    INT = escapeXml(tostring(ability.INT or 10)),
    WIS = escapeXml(tostring(ability.WIS or 10)),
    CHA = escapeXml(tostring(ability.CHA or 10)),
    BACKGROUND = escapeXml(character.background or ""),
    ALIGNMENT = escapeXml(character.alignment or ""),
    SKILLS_CSV = escapeXml(skillsCsv(character)),
    EQUIP_MAIL = escapeXml(equipmentName(character, "mail")),
    EQUIP_HELM = escapeXml(equipmentName(character, "helm")),
    EQUIP_GLOVE = escapeXml(equipmentName(character, "glove")),
    EQUIP_BOOT = escapeXml(equipmentName(character, "boot")),
    WEAPON_NAME = escapeXml(firstWeapon.name or ""),
    WEAPON_BONUS = escapeXml(firstWeapon.atkBonus or ""),
    WEAPON_DAMAGE = escapeXml(firstWeapon.damage or ""),
    ABILITY_NAME = escapeXml(firstAbility.name or ""),
    ABILITY_TYPE = escapeXml(firstAbility.actionType or "action"),
  })
end

return CharacterSheetRenderer
