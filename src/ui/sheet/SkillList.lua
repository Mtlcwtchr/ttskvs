local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")

local SkillList = {}

SkillList.defaults = {}

local DEFAULT_SKILLS = {
  { name = "Perception", ability = "Wis", bonus = 7 },
  { name = "Survival", ability = "Wis", bonus = 7 },
  { name = "Insight", ability = "Wis", bonus = 7 },
  { name = "Animal Handling", ability = "Wis", bonus = 7 },
  { name = "Intimidation", ability = "Cha", bonus = 5 },
  { name = "Acrobatics", ability = "Dex", bonus = 3 },
  { name = "Stealth", ability = "Dex", bonus = 3 },
  { name = "Sleight of Hand", ability = "Dex", bonus = 6 },
  { name = "Athletics", ability = "Str", bonus = 1 },
  { name = "Medicine", ability = "Wis", bonus = 4 },
  { name = "Arcana", ability = "Int", bonus = 0 },
  { name = "Investigation", ability = "Int", bonus = 0 },
  { name = "Persuasion", ability = "Cha", bonus = 2 },
  { name = "Deception", ability = "Cha", bonus = 2 },
}

function SkillList.render()
  local rows = {}
  local skills = Common.character().skills or {}
  if #skills == 0 then
    skills = DEFAULT_SKILLS
  end

  for _, skill in ipairs(skills) do
    local line = Component.render(Templates.TextLine, {
      FONT_SIZE = 12,
      ALIGNMENT = "MiddleLeft",
      COLOR = Component.color("textCream"),
      CONTENT = table.concat({
        Common.signed(skill.bonus or 0),
        Component.escape(skill.name or ""),
        Component.escape(skill.ability or ""),
      }, "  "),
    })
    table.insert(rows, Component.render(Templates.Box, {
      WIDTH = 272,
      HEIGHT = 22,
      COLOR = Component.color("transparent"),
      CONTENT = line,
    }))
  end
  return Component.join(rows)
end

return SkillList
